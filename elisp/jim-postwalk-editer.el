;; -------- 参考lispy的源码实现 ----------
(require 'cider-client nil t)
(require 'cider-connection nil t)
(require 'cider-eval nil t)
(require 'cider-find nil t)
(require 'cider-debug nil t)

(defcustom cider-connect-method 'cider-jack-in
  "Postwalk需要自己的一套cider服务: jack创建之"
  :type '(choice
          (const cider-jack-in)
          (const cider-connect)
          (function :tag "Custom"))
  :group 'postwalk-editer)

(comment
 ;; 启动Postwalk的cider服务
 (call-interactively cider-connect-method))

(defun cider-load-file (filename)
  (let ((ns-form  (cider-ns-form)))
    (cider-map-repls :auto
      (lambda (connection)
        (when ns-form
          (cider-repl--cache-ns-form ns-form connection))
        (cider-request:load-file
         (cider--file-string filename)
         (funcall cider-to-nrepl-filename-function
                  (cider--server-filename filename))
         (file-name-nondirectory filename)
         connection)))))


(defun eval-nrepl-clojure (str &optional namespace)
  (nrepl-sync-request:eval
   str
   (cider-current-connection)
   namespace))

(comment
 (eval-nrepl-clojure "(fn [x] x)"))

(defun start-postwalk-editer ()
  (interactive)
  (progn
    (call-interactively cider-connect-method)
    (add-hook 'cider-connected-hook
              (lambda ()
                (cider-load-file "postwalk_editer.clj")))))

(provide 'jim-postwalk-editer)
