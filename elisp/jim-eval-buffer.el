(defconst jw-eval-buffer-commands
  '(("js" . "/usr/local/bin/node")
    ("rb" . "/usr/bin/ruby")
    ("coffee" . "/usr/local/bin/coffee")
    ("drb" . "/usr/local/bin/drb")
    ("erb" . "/usr/local/bin/drb")
    ("hs" . "/usr/local/bin/runghc")
    ("md" . "/usr/bin/mdpdf")
    ("swift" . "/usr/bin/swift")
    ("sh" . "/bin/bash")
    ("cpp" . "/usr/bin/clang++")
    ("ss" . "/usr/bin/scheme")
    ("scm" . "/usr/local/bin/scheme")
    ("rkt" . "/usr/bin/racket")
    ("php" . "/usr/bin/php")
    ("pl" . "/usr/bin/perl")
    ("java" . "/usr/bin/javac")
    ("py" . "/anaconda3/bin/python")
    ("ex" . "/usr/local/bin/elixir")
    ("exs" . "/usr/local/bin/elixir")))

(defconst jw-eval-buffer-name "*EVALBUFFER*")

(defun jw-eval-buffer ()
  "Evaluate the current buffer and display the result in a buffer."
  (interactive)
  (save-buffer)
  (let* ((file-name (buffer-file-name (current-buffer)))
         (file-extension (file-name-extension file-name))
         (buffer-eval-command-pair (assoc file-extension jw-eval-buffer-commands)))
    (if buffer-eval-command-pair
        (let ((command (concat (cdr buffer-eval-command-pair) " " file-name)))
          (shell-command-on-region (point-min) (point-max) command jw-eval-buffer-name nil)
          (pop-to-buffer jw-eval-buffer-name)
          (other-window 1)
          (jw-eval-buffer-pretty-up-errors jw-eval-buffer-name)
          (message ".."))
      (message "Unknown buffer type"))))

(defun jw-eval-buffer-pretty-up-errors (buffer)
  "Fix up the buffer to highlight the error message (if it contains one)."
  (save-excursion
    (set-buffer buffer)
    (goto-char (point-min))
    (let ((pos (search-forward-regexp "\\.rb:[0-9]+:\\(in.+:\\)? +" (point-max) t)))
      (if pos (progn
                (goto-char pos)
                (insert-string "\n\n")
                (end-of-line)
                (insert-string "\n"))))))

(defun jw-clear-eval-buffer ()
  (interactive)
  (save-excursion
    (set-buffer jw-eval-buffer-name)
    (kill-region (point-min) (point-max))))

(defun jw-eval-or-clear-buffer (n)
  (interactive "P")
  (cond ((null n) (jw-eval-buffer))
        (t (jw-clear-eval-buffer)))  )

;; 2016对朗说: 非Lisp语言只能依赖于Emacs Lisp机器来完成宏的编辑了, 我们若不能在工作中写Lisp语言的话 => drb + eval-buffer 不要在项目里面编程, 而是给定一个环境(drb)去写兴趣库
(defun jw-eval-js ()
  (interactive)
  (insert "
var _ = require('underscore');
console.log(
    (function () {
        return 111;
    })()
)
"))

(defun jw-eval-rb ()
  (interactive)
  "
puts -> {
  123
}[]
")

(defun jw-eval-cpp ()
  (interactive))

(defun jw-eval-java ()
  (interactive))

(defun jw-eval-py ()
  (interactive))

(provide 'jim-eval-buffer)
