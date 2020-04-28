(require 'emmet-mode)
(require 'css-color-list)

;; https://github.com/smihica/emmet-mode

;; 输入view.abc => M-RET => ` <view class="abc"></view> `

(use-package emmet-mode
  :hook (mhtml-mode nxml-mode css-mode web-mode)
  :bind
  (:map emmet-mode-keymap
        ("M-RET" . 'emmet-expand-line)
        ("M-j" . 'join-two-styles))
  :init
  (add-hook 'mhtml-mode-hook 'emmet-mode)
  (add-hook 'mhtml-mode-hook 'smartparens-mode))

(use-package xml
  :mode ("\\.wxml\\'" . web-mode))

(use-package css-mode
  :mode ("\\.wxss\\'" . css-mode))

(setq-default indent-tabs-mode nil)
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-enable-auto-pairing t)
  (setq web-mode-enable-auto-closing t)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-current-column-highlight t)
  (setq web-mode-script-padding 2))

(with-eval-after-load 'web-mode
  (my-web-mode-hook))

;; web-mode: `C-c C-f`展开和收缩html
;; mhtml-mode: `C-c C-f` 向前一个html表达式, `C-c C-b`是向后一个html表达式
;; web-mode-comment-or-uncomment 是注释html
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

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
;; (call-clj-get-class-names-styles "w-100 h-100")
(defun call-clj-get-class-names-styles (class-name)
  (with-current-buffer (get-cljs-cider-buffer)
    (eval-clj-code
     (format
      "(wechat-clj.util/get-class-names-styles \"%s\")"
      class-name))))

(defun mark-replace (mark-op-fn)
  (let* ((bein-p
          (region-beginning))
         (end-p
          (region-end))
         (new-stri (funcall mark-op-fn (get-mark-content (current-buffer)))))
    (progn
      (kill-region bein-p end-p)
      (insert new-stri))))

(defun class->styles ()
  "对应整体转class失败的情况,用手工来转: herb会导致一些出错的class,尤其是含有伪元素"
  (interactive)
  (mark-replace
   (lambda (marked-stri)
     (call-clj-get-class-names-styles marked-stri))))

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

(comment
 (replace-regexp-in-string
  "\\([0-9|\\.]+\\)r?em"
  "\\1"
  "10em"))

(defun rem-to-rpx ()
  (interactive)
  (replace-regexp-in-string
   "\\([0-9|\\.]+\\)r?em"
   (lambda (s)
     (save-match-data
       (print s)
       (format "%drpx" (* 35 (string-to-number (replace-regexp-in-string "rem|em" "" s))))))
   (get-mark-content (current-buffer))))

(defun replace-rem->rpx ()
  (interactive)
  (let* ((bein-p
          (region-beginning))
         (end-p
          (region-end))
         (new-stri (rem-to-rpx)))
    (progn
      (kill-region bein-p end-p)
      (insert new-stri))))

(defun replace-image ()
  "TODO: 先<img替换为<image,需要<image结尾加个/>, 然后style需要长和宽都要设置,不然小程序会不认高度,导致页面很长"
  (interactive)
  (let* ((bein-p
          (region-beginning))
         (end-p
          (region-end))
         (new-stri
          "" ;; TODO
          ))
    (progn
      (kill-region bein-p end-p)
      (insert new-stri))))

(defun replace-input ()
  "需要<input结尾加个/>"
  (interactive)
  (let* ((bein-p
          (region-beginning))
         (end-p
          (region-end))
         (new-stri
          "" ;; TODO
          ))
    (progn
      (kill-region bein-p end-p)
      (insert new-stri))))

(defun join-two-styles ()
  (interactive)
  (progn
    (goto-char (line-beginning-position))
    (call-interactively #'style-gotochar-to-end)
    (let* ((bein-p
            (region-beginning))
           (end-p
            (region-end))
           (splits (split-string
                    (get-mark-content (current-buffer))
                    "\""))
           (new-stri (concat
                      "style=\""
                      (nth 1 splits)
                      (nth 3 splits)
                      "\"")))
      (progn
        (kill-region bein-p end-p)
        (insert new-stri)))))

(comment
 (run-in-s-exp
  (lambda (start end content)
    (format "%d===%d---%s" start end content))))
(defun run-in-s-exp (op-fn)
  (save-excursion
    (backward-sexp)
    (let ((end (point)))
      (forward-sexp)
      (message "Run in s exp, start: %d, end: %d"  end (point))
      (funcall op-fn
               end (point)
               (buffer-substring-no-properties end (point))))))

(defun isearch-line-forward (&optional regexp-p)
  "行内搜索某个关键字"
  (interactive "P")
  (let* ((beg (line-beginning-position))
         (end (line-end-position))
         (isearch-message-prefix-add "[Line]")
         (isearch-search-fun-function
          `(lambda ()
             (lambda (string &optional bound noerror)
               (save-restriction
                 (narrow-to-region ,beg ,end)
                 (funcall (isearch-search-fun-default)
                          string bound noerror))))))
    (isearch-forward regexp-p)))

(defun isearch-s-exp-forward (&optional regexp-p)
  "S表达式内搜索某个关键字,需要在S表达式的末尾进行执行该命令才行"
  (interactive "P")
  (run-in-s-exp
   (lambda (beg end content)
     (let* ((isearch-message-prefix-add "[Line]")
            (isearch-search-fun-function
             `(lambda ()
                (lambda (string &optional bound noerror)
                  (save-restriction
                    (narrow-to-region ,beg ,end)
                    (funcall (isearch-search-fun-default)
                             string bound noerror))))))
       (isearch-forward regexp-p)))))

(defun get-current-line-number ()
  (string-to-number (format-mode-line "%l")))

(comment
 (search-forward "style=" nil t) ;;nil代表整个文件搜索完, t代表搜索有结果就继续往前

 (while (search-forward "style=" nil t)
   (message "===%d" (get-current-line-number))))
(defun style-gotochar-to-end ()
  (interactive)
  (while (search-forward "style=" (line-end-position) t)
    (search-backward "style=" (line-beginning-position) t)
    (call-interactively #'set-mark-command)
    (while (search-forward "\"" (line-end-position) t)
      (message "style到头了"))))

(defun join-all-two-styles ()
  (interactive)
  (goto-char (point-min))
  (while (search-forward "style=" nil t)
    (progn
      (message "执行join style: %d" (get-current-line-number))
      (call-interactively #'join-two-styles))))

;; 小程序和html的语法兼容表
;; 1. img => <image> </> TODO
;; 2. input => <input /> TODO
;; 3. 两个style自动合并的问题 => 已完成
;; 4. hr => view标签表示 TODO

;; 流程:
;; 1. hiccup生成的页面复制过来
;; 2. replace div view
;; 3. replace em 为 rpx
;; 4. joiin all two styles
;; 注意: 样式差不多了,image必须定义高度和宽度才行,不能只定义宽度 ，然后item也必须给高度

;; --------------- mini-program-cljs 和 Emacs的结合的函数 -------
;; 1. 需要先确保eval了mini-program-cljs.core(C-x C-e)
(defun mpcljs-eval-code (code)
  (with-current-buffer (get-cljs-cider-buffer)
    (eval-clj-code code)))

(defun mpc/alert (var)
  (mpcljs-eval-code
   (format ;; 不能返回函数或者promise不然就emacs会报错
    "(do (mini-program-cljs.js-wx/log %s) true)" var)))

(defun mpc/g-data ()
  (interactive)
  (mpcljs-eval-code
   "(do (evaluate (fn [] (-> (js/getApp) .-globalData))) true)"))

(defun mark-replace (regexps targets)
  (let* ((bein-p
          (region-beginning))
         (end-p
          (region-end))
         (new-stri (->>
                    (current-buffer)
                    (get-mark-content)
                    (replace-regexp-in-string regexps targets))))
    (progn
      (kill-region bein-p end-p)
      (insert new-stri))))

(defun remove-flex ()
  (interactive)
  (let* ((regexps
          (s-join "\\|"
                  (list "flex-direction: column;"
                        "flex-direction: row;"
                        "flex: 1 1 auto;"
                        "display: flex;"))))
    (mark-replace regexps "")))


;; https://juejin.im/post/5c0b6869f265da61137f1725
(defun flex->old ()
  "TODO: flex 布局 转为 普通布局, 时时刻刻想着复用^2=>复利")

(defun old->flex ())

(defun get-rand-color ()
  (nth
   (random (length css-color-list))
   css-color-list))

;; Good Tips: 调试CSS是否错误 , 或者用drag this debug.css
(defun debug-css ()
  (interactive)
  (insert (format "background-color: %s;" (get-rand-color))))

(defun undebug-css ())

(provide 'jim-emmet)
