(setq miniprogram-project-path "")

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

(provide 'jim-miniprogram)