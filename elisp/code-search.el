;; 增加下面h函数到cider包的cider-overlays.el文件下面,
;; 然后(byte-compile-file "cider-overlays.el")
;; => TODO: 如何变成cider的hook来加载进去?
;; TODOS more 有意思的事情,兴趣商业化,而不仅仅兴趣职业化:
;; 1. 通过request来查找线上的代码: 词向量的搜索功能, 代码向量
;; 2. 在Emacs里面完成集合搜索ciderS表达式代码
;; 3. 可以查找Cider的repl历史,自己的文档
;; 4. 根据历史频率出现高的代码模式来写yasnippet代码模板生成=>用于代码生成
;; 5. 找到cider记录错误的地方,报错的地方也要记录到代码历史上来=>虽然是正确的定点,是跳向彼岸的关键
;; 6. elisp写一个函数生成world2vec的词向量文件

(require 'request)

;; (cider-add-his "(map inc [1 2])" "[2 3]" "test.clj")
(defun cider-add-his (in_put out_put buffer_name)
  (let* ((rdata '((in_put . 1) (out_put . 1) (buffer_name . *scratch*)))
         (aa (rplacd (assoc 'in_put rdata) in_put))
         (bb (rplacd (assoc 'out_put rdata) out_put))
         (cc (rplacd (assoc 'buffer_name rdata) buffer_name)))
    (request
      "https://www.txt2code.com/api/sjupyter/add-s-exp-history"
      :type "POST"
      :data rdata
      :parser 'json-read
      :success (cl-function
                (lambda (&key data &allow-other-keys)
                  (message "%S" (cdr (assoc 'out_put data))))))))

(cl-defun cider--make-result-overlay (value &rest props &key where duration (type 'result)
                                            (format (concat " " cider-eval-result-prefix "%s "))
                                            (prepend-face 'cider-result-overlay-face)
                                            &allow-other-keys)
  "Place an overlay displaying VALUE at the position determined by WHERE.
VALUE is used as the overlay's after-string property, meaning it is
displayed at the end of the overlay.
Return nil if the overlay was not placed or if it might not be visible, and
return the overlay otherwise.

Return the overlay if it was placed successfully, and nil if it failed.

This function takes some optional keyword arguments:

  If WHERE is a number or a marker, apply the overlay as determined by
  `cider-result-overlay-position'.  If it is a cons cell, the car and cdr
  determine the start and end of the overlay.
  DURATION takes the same possible values as the
  `cider-eval-result-duration' variable.
  TYPE is passed to `cider--make-overlay' (defaults to `result').
  FORMAT is a string passed to `format'.  It should have
  exactly one %s construct (for VALUE).

All arguments beyond these (PROPS) are properties to be used on the
overlay."
  (declare (indent 1))
  (while (keywordp (car props))
    (setq props (cdr (cdr props))))
  ;; If the marker points to a dead buffer, don't do anything.
  (let ((buffer (cond
                 ((markerp where) (marker-buffer where))
                 ((markerp (car-safe where)) (marker-buffer (car where)))
                 (t (current-buffer)))))
    (with-current-buffer buffer
      (save-excursion
        (when (number-or-marker-p where)
          (goto-char where))
        ;; Make sure the overlay is actually at the end of the sexp.
        (skip-chars-backward "\r\n[:blank:]")
        (let* ((beg (if (consp where)
                        (car where)
                      (save-excursion
                        (clojure-backward-logical-sexp 1)
                        (point))))
               (end (if (consp where)
                        (cdr where)
                      (pcase cider-result-overlay-position
                        ('at-eol (line-end-position))
                        ('at-point (point)))))
               (display-string (format format value))
               ;; === 记录历史
               (temp-var-a
                (cider-add-his
                 (format "%s" (apply #'buffer-substring-no-properties (cider-last-sexp 'bounds)))
                 (format "%s" display-string)
                 (format "%s" (buffer-file-name (window-buffer (minibuffer-selected-window))))))
               ;;
               (o nil))
          (remove-overlays beg end 'category type)
          (funcall (if cider-overlays-use-font-lock
                       #'font-lock-prepend-text-property
                     #'put-text-property)
                   0 (length display-string)
                   'face prepend-face
                   display-string)
          ;; If the display spans multiple lines or is very long, display it at
          ;; the beginning of the next line.
          (when (or (string-match "\n." display-string)
                    (> (string-width display-string)
                       (- (window-width) (current-column))))
            (setq display-string (concat " \n" display-string)))
          ;; Put the cursor property only once we're done manipulating the
          ;; string, since we want it to be at the first char.
          (put-text-property 0 1 'cursor 0 display-string)
          (when (> (string-width display-string) (* 3 (window-width)))
            (setq display-string
                  (concat (substring display-string 0 (* 3 (window-width)))
                          (substitute-command-keys
                           "...\nResult truncated. Type `\\[cider-inspect-last-result]' to inspect it."))))
          ;; Create the result overlay.
          (setq o (apply #'cider--make-overlay
                         beg end type
                         'after-string display-string
                         props))
          (pcase duration
            ((pred numberp) (run-at-time duration nil #'cider--delete-overlay o))
            (`command
             ;; If inside a command-loop, tell `cider--remove-result-overlay'
             ;; to only remove after the *next* command.
             (if this-command
                 (add-hook 'post-command-hook
                           #'cider--remove-result-overlay-after-command
                           nil 'local)
               (cider--remove-result-overlay-after-command))))
          (when-let* ((win (get-buffer-window buffer)))
            ;; Left edge is visible.
            (when (and (<= (window-start win) (point) (window-end win))
                       ;; Right edge is visible. This is a little conservative
                       ;; if the overlay contains line breaks.
                       (or (< (+ (current-column) (string-width value))
                              (window-width win))
                           (not truncate-lines)))
              o)))))))

(require 'cl-lib)

(defun company-code-search-backend (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-code-search-backend))
    (prefix (when (looking-back "foo\\>")
              (match-string 0)))
    (candidates (when (equal arg "foo")
                  (list "foobar" "foobaz" "foobarbaz")))
    (meta (format "This value is named %s" arg))))

;; 1. 看看当前激活的是什么 company-backends C-h v
;; 2. 然后自己写一个company-backend或者使用已有的backend，并添加到company-backends中
;; 3. https://github.com/company-mode/company-mode/wiki/Writing-backends
(add-to-list 'company-backends #'company-code-search-backend)

;; -------- 输入关键词之后的补全 ----------
(defvar company-code-search-advanced-keywords
  '(("foo" "overload 1") ("foo" "overload 2") ("bar" "method 1")))

(defun company-code-search-advanced--make-candidate (candidate)
  (let ((text (car candidate))
        (meta (cadr candidate)))
    (propertize text 'meta meta)))

(defun company-code-search-advanced--candidates (prefix)
  (let (res)
    (dolist (item company-code-search-advanced-keywords)
      (when (string-prefix-p prefix (car item))
        (push (company-code-search-advanced--make-candidate item) res)))
    res))

(defun company-code-search-advanced--meta (candidate)
  (format "This will use %s of %s"
          (get-text-property 0 'meta candidate)
          (substring-no-properties candidate)))

(defun company-code-search-advanced--annotation (candidate)
  (format " (%s)" (get-text-property 0 'meta candidate)))

(defun company-code-search-advanced (command &optional arg &rest ignored)
  (interactive (list 'interactive))
  (cl-case command
    (interactive (company-begin-backend 'company-code-search-advanced))
    (prefix (company-grab-symbol-cons "\\.\\|->|-a>" 2))
    (candidates (company-code-search-advanced--candidates arg))
    (annotation (company-code-search-advanced--annotation arg))
    (meta (company-code-search-advanced--meta arg))))

;; (add-to-list 'company-backends #'company-code-search-advanced)

(provide 'code-search)
