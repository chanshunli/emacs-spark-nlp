(require 'clomacs)

(defun init-clomacs ()
  (setq default-directory "~/.emacs.d")
  (clomacs-defun get-property System/getProperty)
  (message "启动clojure repl: %s" (get-property "java.version")))
(init-clomacs)


(provide 'jim-mxnet)
