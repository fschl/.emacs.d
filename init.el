;; basic settings
(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  ;; (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
  (package-initialize)
  )

(set-face-attribute 'default nil :height 80)
(setq inhibit-startup-echo-area-message t) ;; prevent startup messages
(setq inhibit-startup-message t)           ;; prevent startup messages
(setq frame-title-format "%b - emacs") ;; show buffername in titlebar
(setq make-backup-files nil) ;; no more file~
(setq require-final-newline t)
(fringe-mode '(4 . 4))
(setq visible-bell t)
(scroll-bar-mode 0)
(fset 'yes-or-no-p 'y-or-n-p) ;; shorten yes-no answers
(tool-bar-mode 0) ;; disable toolbar
(menu-bar-mode 0)
(line-number-mode 1)
(global-linum-mode 1)
(column-number-mode 1)
(show-paren-mode 1) ;; highlight matching braces
(setq-default indent-tabs-mode nil) ;; do not indent to "next word prev. line"
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)
(setq global-auto-revert-mode 1)

(add-hook 'local-write-file-hooks
          (lambda ()
            (delete-trailing-whitespace)
            nil))

;; faster TRAMP
(setq tramp-default-method "ssh")

;; use Helm for eshell completion
;; https://github.com/emacs-helm/helm/wiki#helmeshellcompletion
(defun pcomplete/sudo ()
  (let ((prec (pcomplete-arg 'last -1)))
    (cond ((string= "sudo" prec)
           (while (pcomplete-here*
                   (funcall pcomplete-command-completion-function)
                   (pcomplete-arg 'last) t))))))

(add-to-list 'load-path "~/.emacs.d/ergoemacs-keybindings")

;; some more eshell stuffs
(defun fschl/eshell-here ()
  "Opens up a new shell in the directory associated with the current buffer's file."
  (interactive)
  (let* ((parent (file-name-directory (buffer-file-name)))
         (name   (car
                  (last
                   (split-string parent "/" t)))))
    (split-window-vertically)
    (other-window 1)
    (eshell "new")
    (rename-buffer (concat "*eshell: " name "*"))

    (insert (concat "ls"))
    (eshell-send-input)))

;;http://emacs.stackexchange.com/questions/5608/how-to-let-eshell-remember-sudo-password-for-two-minutes/5619#5619
;; (require 'em-tramp) ; to load eshell’s sudo
;; (require 'em-smart)
;; (setq eshell-prefer-lisp-variables t)
(setq password-cache t) ; enable password caching
(setq password-cache-expiry 3600) ; for one hour (time in secs)

(global-set-key (kbd "C-!") 'fschl/eshell-here)
(add-hook 'eshell-preoutput-filter-functions
          'ansi-color-apply)

(add-hook 'eshell-mode-hook
          (lambda ()
            (local-set-key (kbd "C-r") 'helm-eshell-history)
            (define-key eshell-mode-map
              [remap eshell-pcomplete]
              'helm-esh-pcomplete)
            (linum-mode -1)
            ))


(defun delete-single-window (&optional window)
  "Remove WINDOW from the display.  Default is `selected-window'.
If WINDOW is the only one in its frame, then `delete-frame' too."
  (interactive)
  (save-current-buffer
    (setq window (or window (selected-window)))
    (select-window window)
    (kill-buffer)
    (if (one-window-p t)
        (delete-frame)
      (delete-window (selected-window)))))

(defun eshell/x (&rest args)
  (delete-single-window))


(require 'tex)
(setq-default TeX-PDF-mode t)
(require 'dired-details+)
(require 'js2-mode)
(require 'js2-refactor)
(require 'revive)
(require 'markdown-mode)
(require 'auto-complete)
;;(require 'indent-guide)
;;(indent-guide-global-mode)
;;(setq indent-guide-recursive 0)

(add-hook 'dired-mode-hook
    (lambda()
    (linum-mode -1)))

(require 'git-gutter)
(global-git-gutter-mode t)
(git-gutter:linum-setup)

;; MAGIT
(if (eq system-type 'gnu/linux) ;; only use magit on linux
    (require 'magit))

;; web-mode.org, when your html has embedded css & javascript
(require 'web-mode)
(defun fschl-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 4)
  (setq web-mode-code-indent-offset 4)
  (setq web-mode-script-padding 4)
  (setq web-mode-style-padding 4)
  (setq web-mode-enable-current-element-highlight t)
  ;;(yas-activate-extra-mode 'html-mode)
  )

(add-hook 'web-mode-hook  'fschl-web-mode-hook)
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.htm\\'" . web-mode))

;; load ErgoEmacs keybinding
(setenv "ERGOEMACS_KEYBOARD_LAYOUT" "de") ; DE
(load "ergoemacs-mode.el")
(ergoemacs-mode 1) ;; turn on minor mode ergoemacs-mode

;; H E L M stuffs
(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebihnd tab to do persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(setq helm-quick-update                     t ; do not display invisible candidates
      helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t)

(helm-mode 1)


;; projectile
(require 'projectile)
(setq projectile-indexing-method 'native)
(setq projectile-globally-ignored-directories (append '("*git") projectile-globally-ignored-directories))
(setq projectile-globally-ignored-files (append '("*.o" "*.elc" "*git") projectile-globally-ignored-files))
(setq projectile-enable-caching t)
(setq projectile-completion-system 'helm)
(projectile-global-mode t)
(require 'helm-projectile)
(eval-after-load "projectile"
  '(setq projectile-mode-line
         '(:eval (list " P["
                       (propertize (projectile-project-name)
                                   'face '(:foreground "#BC1737"))
                       "]"))))


;; some K E Y B O A R D rebindings
(global-set-key [f4] 'goto-line)
(global-set-key [f3] 'helm-swoop)
(js2r-add-keybindings-with-prefix "C-c C-r")

(global-set-key (kbd "M-t") 'indent-region)
(if (fboundp 'magit-status) ;; works only if magit loaded...not the case in Windows
    (global-set-key (kbd "M-m") 'magit-status))
(global-set-key (kbd "C-.") 'helm-imenu-anywhere)
(global-set-key (kbd "C-,") 'helm-imenu)


;; enable easy window resizing
(global-set-key (kbd "M-<up>"   ) 'enlarge-window)
(global-set-key (kbd "M-<down>" ) 'shrink-window)
(global-set-key (kbd "M-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-<left>" ) 'shrink-window-horizontally)
;; quicker keyboard macros
(global-set-key [f10]  'start-kbd-macro)
(global-set-key [f11]  'end-kbd-macro)
(global-set-key [f12]  'call-last-kbd-macro)

;; resize to 81 columns http://nullprogram.com/blog/2010/10/06/
(defun set-window-width (n)
  "Set the selected window's width."
  (adjust-window-trailing-edge (selected-window) (- n (window-width)) t))
(defun set-81-columns ()
  "Set the selected window to 81 columns."
  (interactive)
  (set-window-width 91))

(global-set-key [f9] 'set-81-columns)

;; yasnippet
(require 'yasnippet)
(yas-global-mode 1)
(global-set-key (kbd "M-ß") 'yas/expand)


;; golang path & modes
(load "~/.emacs.d/go.el")

(ac-config-default)
(setq ac-use-menu-map t)
(setq ac-use-fuzzy t)
(setq ac-auto-start 1)
(setq ac-ignore-case t)
(setq ac-menu-height 20)
(define-key ac-menu-map "\C-n" 'ac-next)
(define-key ac-menu-map "\C-p" 'ac-previous)
(define-key ac-menu-map "\M-k" 'ac-next)
(define-key ac-menu-map "\M-i" 'ac-previous)

;;(setq ac-source-yasnippet nil)
;; (ac-set-trigger-key "TAB")
;; (ac-set-trigger-key "<tab>")
;;; set the trigger key so that it can work together with yasnippet on tab key,
;;; if the word exists in yasnippet, pressing tab will cause yasnippet to
;;; activate, otherwise, auto-complete will
;; (ac-set-trigger-key "TAB")
;; (ac-set-trigger-key "<tab>")
;; (require 'auto-complete-auctex)

;; make yasnippet use popup from auto-complete
;; add some shotcuts in popup menu mode
(require 'popup)
;; (define-key popup-menu-keymap (kbd "M-k") 'popup-next)
;; (define-key popup-menu-keymap (kbd "M-i") 'popup-previous)

(defun yas/popup-isearch-prompt (prompt choices &optional display-fn)
  (when (featurep 'popup)
    (popup-menu*
     (mapcar
      (lambda (choice)
        (popup-make-item
         (or (and display-fn (funcall display-fn choice))
             choice):value choice))
      choices)
     :prompt prompt
     ;; start isearch mode immediately
     :isearch t
     )))

(setq yas/prompt-functions '(yas/popup-isearch-prompt yas/no-prompt))


;; sadly doesnt work as intended. check/try/fix later
;; ;; fix yasnippets 'TAB' after loading js2-mode
;; (defun js2-tab-properly ()
;;   (interactive)
;;   (let ((yas/fallback-behavior 'return-nil))
;;     (unless (yas/expand)(indent-for-tab-command)
;;             (if (looking-back "^\s*")(back-to-indentation)))))

;; (define-key js2-mode-map (kbd "TAB") 'js2-tab-properly)

;; ;; another attempt to fix YASnippet vs. js2-mode
;; (defun iy-tab-noconflict ()(let ((command (key-binding [tab]))) ; remember command
;; (local-unset-key [tab]) ; unset from (kbd "<tab>")
;; (local-set-key (kbd "TAB") command))) ; bind to (kbd "TAB")
(require 'diminish)
(diminish 'ergoemacs-mode)
(diminish 'helm-mode)

(diminish 'auto-complete-mode "AC")
(diminish 'git-gutter-mode)
(diminish 'go-oracle-mode)
(diminish 'yas-minor-mode "Y")

(add-hook 'js2-init-hook
          (lambda ()
            (setq mode-name "js2")))

(add-hook 'markdown-mode-hook
          (lambda ()
            (setq mode-name "MD")
            ('git-gutter-mode)))


;; filename associations for MarkDown
(setq auto-mode-alist (cons '("\\.markdown" . markdown-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.mdown" . markdown-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.md" . markdown-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.js" . js2-mode) auto-mode-alist))    ;; JS2-mode
(setq auto-mode-alist (cons '("Gemfile*" . ruby-mode) auto-mode-alist)) ;; ruby-mode
(setq auto-mode-alist (cons '("\\.tex*" . latex-mode) auto-mode-alist)) ;; latex-mode


;; add mode for Dockerfiles
(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("Dockerfile*" . dockerfile-mode))
(add-hook 'dockerfile-mode-hook
          'git-gutter-mode)

;; turn on spellchecking for textfiles
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'python-mode-hook 'flyspell-prog-mode)

;;(load "~/auctex.el" nil t t)
(defun build-view ()
  (interactive)
  (if (buffer-modified-p)
      (progn
        (let ((TeX-save-query nil))
          (TeX-save-document (TeX-master-file)))
        (setq build-proc (TeX-command "LaTeX" 'TeX-master-file -1))
        (setq build-proc (TeX-command "BibTeX" 'TeX-master-file -1))
        (setq build-proc (TeX-command "LaTeX" 'TeX-master-file -1))
        (setq build-proc (TeX-command "LaTeX" 'TeX-master-file -1))
        (set-process-sentinel  build-proc  'build-sentinel))))

(defun build-sentinel (process event)
  (if (string= event "finished\n")
      (TeX-view)
    (message "Errors! Check with C-`")))
(add-hook 'LaTeX-mode-hook '(lambda () (local-set-key (kbd "<f5>") 'build-view)))

;; Org-mode awesomeness!
(setq org-agenda-files (quote ("~/Documents/Org/uni.org"
                               "~/Documents/Org/projects.org"
                               "~/Documents/Org/private.org")))
(add-hook 'org-mode-hook
          (lambda ()
            (linum-mode -1)
            ))

(global-set-key "\C-cl" 'org-store-link)
(global-set-key (kbd "<f8>") 'org-agenda)
(global-set-key (kbd "<f7>") 'org-cycle-agenda-files)
;; (global-set-key "\C-ca" 'org-agenda) ;; already have f8
(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))
(setq org-use-fast-todo-selection t)
(setq org-treat-S-cursor-todo-selection-as-state-change nil)
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("MEETING" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))

;; revive.el - restore Windowsetup
(autoload 'save-current-configuration "revive" "Save status" t)
(autoload 'resume "revive" "Resume Emacs" t)
(autoload 'wipe "revive" "Wipe Emacs" t)
(define-key ctl-x-map "S" 'save-current-configuration)
(define-key ctl-x-map "F" 'resume)
(define-key ctl-x-map "K" 'wipe)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(before-save-hook (quote (gofmt-before-save)))
 '(custom-enabled-themes (quote (tango-dark)))
 '(custom-safe-themes
   (quote
    ("c74e83f8aa4c78a121b52146eadb792c9facc5b1f02c917e3dbb454fca931223" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" "f0b0710b7e1260ead8f7808b3ee13c3bb38d45564e369cbe15fc6d312f0cd7a0" "3c83b3676d796422704082049fc38b6966bcad960f896669dfc21a7a37a748fa" default)))
 '(dired-listing-switches "-ahsl")
 '(eshell-visual-commands
   (quote
    ("vi" "screen" "top" "less" "more" "lynx" "ncftp" "pine" "tin" "trn" "elm" "htop")))
 '(git-gutter:update-interval 1)
 '(org-agenda-files
   (quote
    ("~/Documents/Org/startup.org" "~/Documents/Org/uni.org" "~/Documents/Org/projects.org")) t)
 '(same-window-regexps (quote ("\\*magit: *")))
 '(sgml-basic-offset 4)
 '(sml/mode-width 30)
 '(sml/name-width 18)
 '(sml/replacer-regexp-list
   (quote
    (("^~/org/" ":Org:")
     ("^~/\\.emacs\\.d/" ":ED:")
     ("^/sudo:.*:" ":SU:")
     ("^~/Documents/" "Doc:")
     ("^~/projects/" ":P:"))))
 '(sml/show-eol t))


(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:background "#115522" :foreground "#223436" :box (:line-width -1 :style released-button)))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "white smoke" :box (:line-width 1 :color "lawn green")))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "white smoke" :box (:line-width 1 :color "medium spring green")))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "white smoke" :box (:line-width 1 :color "magenta")))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "white smoke" :box (:line-width 1 :color "goldenrod")))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "white smoke" :box (:line-width 1 :color "chocolate")))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "white smoke" :box (:line-width 1 :color "dodger blue")))))
 '(rainbow-delimiters-unmatched-face ((t (:background "black" :foreground "#88090B"))))
 '(sml/modes ((t :inherit sml/global :foreground "#669933"))))

(require 'smart-mode-line)
;; (setq sml/theme 'powerline)
;; (setq powerline-default-separator-dir '(right . left))
(sml/setup)
(put 'erase-buffer 'disabled nil)
