(require 'clomacs)

(clomacs-defun jim-mxnet-set-emacs-connection
               clomacs/set-emacs-connection
               :lib-name "jim-mxnet")
(clomacs-defun jim-mxnet-close-emacs-connection
               clomacs/close-emacs-connection
               :lib-name "jim-mxnet")
(clomacs-defun jim-mxnet-require
               clojure.core/require
               :lib-name "jim-mxnet")

(defun jim-mxnet-httpd-start ()
  (cl-flet ((clomacs-set-emacs-connection 'jim-mxnet-set-emacs-connection)
            (clomacs-require 'jim-mxnet-require))
    (clomacs-httpd-start)))

(defun jim-mxnet-httpd-stop ()
  (cl-flet ((clomacs-close-emacs-connection 'jim-mxnet-close-emacs-connection)
            (clomacs-require 'jim-mxnet-require))
    (clomacs-httpd-stop)))

(clomacs-defun jim-mxnet-md-to-html-wrapper
               my-md-to-html-string
               :namespace jim-mxnet.core
               :lib-name "jim-mxnet"
               :doc "Convert markdown to html via clojure lib.")

(defun jim-mxnet-mdarkdown-to-html (beg end)
  "Add to the selected markdown text it's html representation."
  (interactive "r")
  (save-excursion
    (if (< (point) (mark))
        (exchange-point-and-mark))
    (insert
     (concat "\n" (jim-mxnet-md-to-html-wrapper
                   (buffer-substring beg end))))))

(clomacs-defun jim-mxnet-strong-emacs-version
               strong-emacs-version
               :namespace jim-mxnet.core
               :lib-name "jim-mxnet"
               :doc "Get Emacs version with markdown strong marks."
               :httpd-starter 'jim-mxnet-httpd-start)

(clomacs-defun jim-mxnet-dot-word
               jim-mxnet.tensorflow/dot-word
               :lib-name "jim-mxnet")

(clomacs-defun jim-mxnet-get-word-vector
               jim-mxnet.tensorflow/get-word-vector
               :lib-name "jim-mxnet")

(comment
 (jim-mxnet-get-word-vector "python") ;=> 输出词向量,但是两个参数,就不知道怎么定义对接了
 (jim-mxnet-dot-word "apple" "steve") ;=> Not enough arguments for format string
;; => ;; =>
 )

(provide 'jim-mxnet)

;; (jim-mxnet-httpd-start)
;; (add-to-list 'load-path "~/.emacs.d/jim-mxnet/src/elisp/")
;; (require 'jim-mxnet)
;; (jim-mxnet-md-to-html-wrapper "# This is a test")
;; # This is a test
;; (jim-mxnet-md-to-html-wrapper (jim-mxnet-strong-emacs-version))
