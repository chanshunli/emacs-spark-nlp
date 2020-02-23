(require 'emmet-mode)

;;(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
;;(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
;;(add-hook 'emmet-mode-hook (lambda () (setq emmet-indent-after-insert nil)))
;;(add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2))) ;; indent 2 spaces.

;;  不知道为什么这个use-package的东西没有生效: 是因为web-mode打不开?的错误
(use-package emmet-mode
  :hook (mhtml-mode nxml-mode css-mode)
  :bind
  (:map emmet-mode-keymap
        ;; ("C-c e" . 'emmet-expand-line)
        ("M-RET" . 'emmet-expand-line)
        ) ;; 没有生效
  :init
  (add-hook 'mhtml-mode-hook 'emmet-mode)
  ;; (add-hook 'web-mode-hook 'emmet-mode)
  )

(add-hook 'mhtml-mode-hook 'emmet-mode)
;; (add-hook 'web-mode-hook 'emmet-mode)

(add-hook 'mhtml-mode-hook 'smartparens-mode)

;; (global-set-key "M-RET" 'emmet-expand-line) ;;=> 报错
;; Debugger entered--Lisp error: (error "Key sequence C - R E T starts with non-prefix key ...")

;; (global-set-key "C-c e" 'emmet-expand-line)

(use-package xml
  :mode ("\\.wxml\\'" . mhtml-mode))

(use-package css-mode
  :mode ("\\.wxss\\'" . css-mode))

(provide 'jim-emmet)
