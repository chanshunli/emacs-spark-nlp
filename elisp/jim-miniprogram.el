;; (setq miniprogram-project-path "")
;; (setq miniprogram-file "")

(require 'jim-env)

(defun show-cli-status ()
  (shell-command-to-string "lsof -nP -iTCP:9420 -sTCP:LISTEN "))

(defun open-cli-ws (success-fn)
  "小程序模拟器的ws打开"
  (make-process
   :name "open cli ws"
   :command (list  "/Applications/wechatwebdevtools.app/Contents/MacOS/cli"
                   "--auto" miniprogram-project-path "--auto-port" "9420")
   :sentinel `(lambda (proc event)
                (progn
                  (message "finished open cli ws!")

                  (funcall ,success-fn "ok")
                  ;; (sit-for 10) ;; 线程不阻塞的
                  ;; (message "===PORT==%s" ,(show-cli-status))
                  ))
   :buffer "*mini-program-cljs # open cli ws*"))

(comment
 (open-cli-ws (lambda (x) (message x))))

(defun miniprogram-jack ()
  (interactive)
  "TODO: 需要自己选node-repl"
  (open-cli-ws
   (lambda (x)
     (progn
       (find-file miniprogram-file)
       (with-current-buffer "foo.cljs"
         (push-it-real-good
          "M-x" "cider-jack-in-cljs"
          ;; "shadow-cljs" ;; 无效
          "<return>"))))))

(provide 'jim-miniprogram)
