(require 'package)

(setq package-archives
      '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
        ("melpa" . "http://elpa.emacs-china.org/melpa/")
        ("melpa-stable" . "http://elpa.emacs-china.org/melpa-stable/")))

(setq package-selected-packages
      '(helm
	cider
	clojure-mode
	smartparens
	projectile
	company
	helm-projectile
	monokai-theme))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(dolist (package package-selected-packages)
  (when (and (assq package package-archive-contents)
             (not (package-installed-p package)))
    (package-install package t)))

