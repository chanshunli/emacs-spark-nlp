(require 'emmet-mode)

;; https://github.com/smihica/emmet-mode

;; 输入view.abc => M-RET => ` <view class="abc"></view> `

(use-package emmet-mode
  :hook (mhtml-mode nxml-mode css-mode)
  :bind
  (:map emmet-mode-keymap
        ("M-RET" . 'emmet-expand-line))
  :init
  (add-hook 'mhtml-mode-hook 'emmet-mode)
  (add-hook 'mhtml-mode-hook 'smartparens-mode))

(use-package xml
  :mode ("\\.wxml\\'" . mhtml-mode))

(use-package css-mode
  :mode ("\\.wxss\\'" . css-mode))

(defun get-mark-content (buffername)
  (with-current-buffer
      buffername
    (buffer-substring-no-properties
     (region-beginning)
     (region-end))))

;; 小程序的: div 换为 view
;;  replace-string div 换为 view => (sgml-pretty-print BEG END) 格式化
(defun replace-div->view ()
  (interactive)
  (let* ((bein-p
          (region-beginning))
         (end-p
          (region-end))
         (new-stri
          (->>
           (get-mark-content (current-buffer))
           (replace-regexp-in-string
            "div" "view")
           (replace-regexp-in-string
            "class=\"[A-Za-z| |0-9|-]+\""
            (lambda (s)
              (save-match-data
                (print (concat "替换class: " s))
                (concat "style=\""
                        (call-clj-get-class-names-styles
                         (replace-regexp-in-string
                          "class=" ""
                          (replace-regexp-in-string "\"" "" s)))
                        "\"")))))))
    (progn
      ;; 1.替换为view的标签名字
      (kill-region bein-p end-p)
      (insert new-stri)
      ;; 2.格式化
      (sgml-pretty-print bein-p (point)))))

;; 将class的名称翻译为行内样式的内容,避免再自己一个个重新找
;; class name to inline style => Replacing class styles with inline styles
;; document.styleSheets[0].cssRules

(defun get-cljs-cider-buffer ()
  (->>
   (buffer-list)
   (-filter
    (lambda (buffer)
      (string-match
       "\\(.*\\)cider\\(.*\\)cljs\\(.*\\)"
       (buffer-name buffer))))
   first))

;; 用mutil-cursors来选中编辑
;; (call-clj-get-class-names-styles "w-100")
(defun call-clj-get-class-names-styles (class-name)
  (with-current-buffer (get-cljs-cider-buffer)
    (eval-clj-code
     (format
      "(biancheng-common.util/get-class-names-styles \"%s\")"
      class-name))))

;; M-x replace-regexp Replace regexp (default \(.*\) → \,(call-clj-get-class-names-styles \1)):

(defun match-underscore ()
  "return matched text with underscore replaced by space."
  (replace-regexp-in-string "_" " " (match-string 1)))

;; (flatten-string-with-links "this is a [[http://link][description]]")
;; => "this is a description"
(defun flatten-string-with-links (string)
  (replace-regexp-in-string
   "\\[\\[[a-zA-Z:%@/\.]+\\]\\[[a-zA-Z:%@/\.]+\\]\\]"
   (lambda (s)
     (save-match-data
       ;; (print s);;=> "[[http://link][description]]"
       (nth 2 (split-string s "[\]\[]+")))) string))

(provide 'jim-emmet)
