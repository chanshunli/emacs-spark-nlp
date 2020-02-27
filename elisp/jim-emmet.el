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
          (replace-regexp-in-string
           "div" "view"
           (get-mark-content (current-buffer)))))
    (progn
      ;; 1.替换为view的标签名字
      (kill-region bein-p end-p)
      (insert new-stri)
      ;; 2.格式化
      (sgml-pretty-print bein-p (point)))))

;; 将class的名称翻译为行内样式的内容,避免再自己一个个重新找
;; class name to inline style => Replacing class styles with inline styles
;; document.styleSheets[0].cssRules

(provide 'jim-emmet)
