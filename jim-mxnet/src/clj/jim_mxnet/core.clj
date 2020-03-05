(ns jim-mxnet.core
  (:use markdown.core
        clomacs))

(defn my-md-to-html-string
  "Call some function from the dependency."
  [x]
  (md-to-html-string x))

(clomacs-defn emacs-version emacs-version)

(defn strong-emacs-version []
  (let [ev (.replaceAll (emacs-version) "\n" "")]
    (str "**" ev "**")))

;; (emacs-version)
;; (md-to-html-string (strong-emacs-version))
