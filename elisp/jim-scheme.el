;; Chez Scheme: https://www.yinwang.org/blog-cn/2013/04/11/scheme-setup
(require 'cmuscheme)
;; `C-x C-e` scm文件 就会弹出来需要填入scheme
(setq scheme-program-name "scheme")

;; bypass the interactive question and start the default interpreter
(defun scheme-proc ()
  "Return the current Scheme process, starting one if necessary."
  (unless (and scheme-buffer
               (get-buffer scheme-buffer)
               (comint-check-proc scheme-buffer))
    (save-window-excursion
      (run-scheme scheme-program-name)))
  (or (scheme-get-process)
      (error "No current process. See variable `scheme-buffer'")))

(defun scheme-split-window ()
  (cond
   ((= 1 (count-windows))
    (delete-other-windows)
    (split-window-vertically (floor (* 0.68 (window-height))))
    (other-window 1)
    (switch-to-buffer "*scheme*")
    (other-window 1))
   ((not (find "*scheme*"
               (mapcar (lambda (w) (buffer-name (window-buffer w)))
                       (window-list))
               :test 'equal))
    (other-window 1)
    (switch-to-buffer "*scheme*")
    (other-window -1))))

(defun scheme-send-last-sexp-split-window ()
  (interactive)
  (scheme-split-window)
  (scheme-send-last-sexp))

(defun scheme-send-definition-split-window ()
  (interactive)
  (scheme-split-window)
  (scheme-send-definition))


(add-hook
 'scheme-mode-hook
 (lambda ()
   (define-key scheme-mode-map (kbd "<f5>") 'scheme-send-last-sexp-split-window)
   (define-key scheme-mode-map (kbd "<f6>") 'scheme-send-definition-split-window)))

(add-hook 'scheme-mode-hook 'lispy-mode)

(provide 'jim-scheme)
