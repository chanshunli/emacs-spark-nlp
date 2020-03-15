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
                  (funcall ,success-fn "ok")))
   :buffer "*mini-program-cljs # open cli ws*"))

(comment
 (open-cli-ws (lambda (x) (message x)))

 ;; 默认选择shadow-cljs构建,都无效的设置变量尝试
 (setq cider-default-repl-command 'shadow)
 (setq cider-default-cljs-repl 'shadow)
 (setq cider-jack-in-default 'shadow-cljs))

(defun miniprogram-jack ()
  (interactive)
  "需要自己选 shadow-cljs & node-repl"
  (open-cli-ws
   (lambda (x)
     (progn
       (find-file miniprogram-file)
       (with-current-buffer "core.cljs"
         (progn
           (call-interactively #'cider-jack-in-cljs)))))))

(provide 'jim-miniprogram)
