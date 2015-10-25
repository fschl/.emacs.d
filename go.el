;; stuff for golang!
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/go/bin"))
(setenv "GOPATH" (concat (getenv "GOPATH") ":/home/kani/projects/go-projects"))
(setq exec-path (append exec-path '("/usr/local/go/bin")))

(require 'go-mode)
(load "~/.emacs.d/go-autocomplete.el")
(load "~/projects/go-projects/src/golang.org/x/tools/cmd/oracle/oracle.el")

(require 'go-autocomplete)
(require 'auto-complete-config)

;; auto-format before save
(add-hook 'before-save-hook 'gofmt-before-save)
(add-hook 'go-mode-hook
          'go-oracle-mode
          'git-gutter-mode)

(defun fschl-go-mode-keys ()
  "some of my keybinds for `go-mode'"
  (interactive)
  (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
  (local-set-key (kbd "C-c C-g") 'go-goto-imports)
  (local-set-key (kbd "C-c C-k") 'godoc)
  (setq go-oracle-set-scope "gitlab.opendriverslog.de/odl/goodl gitlab.opendriverslog.de/odl/goodl-lib gitlab.opendriverslog.de/odl/webfw")
  (go-oracle-mode)
)

(defun fschl-goodl-scope ()
  "set current go-oracle scope to goodl + lib + webfw"
  (interactive)
  (setq go-oracle-scope "gitlab.opendriverslog.de/odl/goodl gitlab.opendriverslog.de/odl/goodl-lib gitlab.opendriverslog.de/odl/webfw")
)

;; occur todo
(defun fschl-occur-ginkgo ()
  "Search for all It(|By(: in file"
  (interactive)
  (occur "It(\\|By("))
(local-set-key [f3] 'fschl-occur-ginkgo)

(add-hook 'go-mode-hook 'fschl-go-mode-keys)

