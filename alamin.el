
(setq user-full-name "Md. Alamin Mahamud")
(setq user-mail-address "alamin.ineedahelp@gmail.com")

;;  (if (fboundp 'gnutls-available-p)
;;      (fmakunbound 'gnutls-available-p))

(require 'cl)
(setq tls-checktrust t)

(let ((trustfile
       (replace-regexp-in-string
        "\\\\" "/"
        (replace-regexp-in-string
         "\n" ""
         (shell-command-to-string "python -m certifi")))))
  (setq tls-program
        (list
         (format "gnutls-cli%s --x509cafile %s -p %%p %%h"
                 (if (eq window-system 'w32) ".exe" "") trustfile)))
  (setq gnutls-verify-error t)
  (setq gnutls-trustfiles (list trustfile)))

;; Test the settings by using the following code snippet:
;;  (let ((bad-hosts
;;         (loop for bad
;;               in `("https://wrong.host.badssl.com/"
;;                    "https://self-signed.badssl.com/")
;;               if (condition-case e
;;                      (url-retrieve
;;                       bad (lambda (retrieved) t))
;;                    (error nil))
;;               collect bad)))
;;    (if bad-hosts
;;        (error (format "tls misconfigured; retrieved %s ok" bad-hosts))
;;      (url-retrieve "https://badssl.com"
;;                    (lambda (retrieved) t))))

(setq custom-file (concat init-dir "custom.el"))

(load custom-file :noerror)

(setq gc-cons-threshold 50000000)

(setq gnutls-min-prime-bits 4096)

(require 'package)

(defvar gnu '("gnu" . "https://elpa.gnu.org/packages/"))
(defvar melpa '("melpa" . "https://melpa.org/packages/"))
(defvar melpa-stable '("melpa-stable" . "https://stable.melpa.org/packages/"))

;; Add marmalade to package repos
(setq package-archives nil)
(add-to-list 'package-archives melpa-stable t)
(add-to-list 'package-archives melpa t)
(add-to-list 'package-archives gnu t)

(package-initialize)

(unless (and (file-exists-p "~/.emacs.d/elpa/archives/gnu")
             (file-exists-p "~/.emacs.d/elpa/archives/melpa")
             (file-exists-p "~/.emacs.d/elpa/archives/melpa-stable"))
  (package-refresh-contents))

(defun packages-install (&rest packages)
  (message "running packages-install")
  (mapc (lambda (package)
          (let ((name (car package))
                (repo (cdr package)))
            (unless (package-installed-p name)
              (let ((package-archives (list repo)))
                (package-initialize)
                (package-install name)))))
        packages)
  (package-initialize)
  (delete-other-windows))

;; Install extensions if they're missing
(defun init--install-packages ()
  (message "Lets install some packages")
  (packages-install
   ;; Since use-package this is the only entry here
   ;; ALWAYS try to use use-package!
   (cons 'use-package melpa))

)

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

(require 'cl)

(use-package dash
:ensure t
:config (eval-after-load "dash" '(dash-enable-font-lock)))

(use-package s
:ensure t)

(use-package f
:ensure t)

(setq-default indent-tabs-mode nil)
(setq tab-width 2)

(setq-default tab-always-indent 'complete)

(fset 'yes-or-no-p 'y-or-n-p)

(setq scroll-conservatively 10000
      scroll-preserve-screen-position t)

(setq disabled-command-function nil)

(setq initial-scratch-message "Alamin <3 Emacs")

(use-package bm
  :ensure t
  :bind (("C-c =" . bm-toggle)
         ("C-c [" . bm-previous)
         ("C-c ]" . bm-next)))

(use-package counsel
  :ensure t
  :bind
  (("M-x" . counsel-M-x)
   ("M-y" . counsel-yank-pop)
   :map ivy-minibuffer-map
   ("M-y" . ivy-next-line)))

 (use-package swiper
   :pin melpa-stable
   :diminish ivy-mode
   :ensure t
   :bind*
   (("C-s" . swiper)
    ("C-c C-r" . ivy-resume)
    ("C-x C-f" . counsel-find-file)
    ("C-c h f" . counsel-describe-function)
    ("C-c h v" . counsel-describe-variable)
    ("C-c i u" . counsel-unicode-char)
    ("M-i" . counsel-imenu)
    ("C-c g" . counsel-git)
    ("C-c j" . counsel-git-grep)
    ("C-c k" . counsel-ag)
    ("C-c l" . scounsel-locate))
   :config
   (progn
     (ivy-mode 1)
     (setq ivy-use-virtual-buffers t)
     (define-key read-expression-map (kbd "C-r") #'counsel-expression-history)
     (ivy-set-actions
      'counsel-find-file
      '(("d" (lambda (x) (delete-file (expand-file-name x)))
         "delete"
         )))
     (ivy-set-actions
      'ivy-switch-buffer
      '(("k"
         (lambda (x)
           (kill-buffer x)
           (ivy--reset-state ivy-last))
         "kill")
        ("j"
         ivy--switch-buffer-other-window-action
         "other window")))))

(use-package counsel-projectile
  :ensure t
  :config
  (counsel-projectile-on))

(use-package ivy-hydra :ensure t)

(global-set-key (kbd "C-x k") 'kill-this-buffer)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode))

(if (or
     (eq system-type 'darwin)
     (eq system-type 'berkeley-unix))
    (setq system-name (car (split-string system-name "\\."))))

(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
(push "/usr/local/bin" exec-path)

;; /usr/libexec/java_home
;;(setenv "JAVA_HOME" "/Library/Java/JavaVirtualMachines/jdk1.8.0_05.jdk/Contents/Home")

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(setq mac-option-modifier 'none)
(setq mac-command-modifier 'meta)
(setq ns-function-modifier 'hyper)

;; Backup settings
(defvar --backup-directory (concat init-dir "backups"))

(if (not (file-exists-p --backup-directory))
    (make-directory --backup-directory t))

(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )
  (setq delete-by-moving-to-trash t
        trash-directory "~/.Trash/emacs")

  (setq backup-directory-alist `(("." . ,(expand-file-name
                                          (concat init-dir "backups")))))

(setq ns-pop-up-frames nil)

(defun spell-buffer-dutch ()
  (interactive)
  (ispell-change-dictionary "nl_NL")
  (flyspell-buffer))

(defun spell-buffer-english ()
  (interactive)
  (ispell-change-dictionary "en_US")
  (flyspell-buffer))

(use-package ispell
  :config
  (when (executable-find "hunspell")
    (setq-default ispell-program-name "hunspell")
    (setq ispell-really-hunspell t))

  ;; (setq ispell-program-name "aspell"
  ;;       ispell-extra-args '("--sug-mode=ultra"))
  :bind (("C-c N" . spell-buffer-dutch)
         ("C-c n" . spell-buffer-english)))

;;; what-face to determine the face at the current point
(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

(use-package ace-window
  :ensure t
  :config
  (setq aw-keys '(?a ?s ?d ?f ?j ?k ?l ?o))
  (global-set-key (kbd "C-x o") 'ace-window)
:diminish ace-window-mode)

(use-package ace-jump-mode
  :ensure t
  :config
  (define-key global-map (kbd "C-c SPC") 'ace-jump-mode))

;; Custom binding for magit-status
  (use-package magit
    :config
    (global-set-key (kbd "C-c m") 'magit-status))

  (setq inhibit-startup-message t)
;;  (global-linum-mode)

  (defun iwb ()
    "indent whole buffer"
    (interactive)
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max)))

  (global-set-key (kbd "C-c n") 'iwb)

  (electric-pair-mode t)

(use-package arjen-grey-theme
   :ensure t
   :config
   (load-theme 'arjen-grey t))

 ;; (use-package base16-theme
 ;;   :ensure t
 ;;   :config
 ;;   (load-theme 'base16-materia))

(if (or (eq system-type 'darwin)(eq system-type 'gnu/linux) )
    (set-face-attribute 'default nil :font "Hack-16")
  (set-face-attribute 'default nil :font "DejaVu Sans Mono" :height 110))

(use-package command-log-mode
  :ensure t)

(defun live-coding ()
  (interactive)
  (set-face-attribute 'default nil :font "Hack-18")
  (add-hook 'prog-mode-hook 'command-log-mode)
  ;;(add-hook 'prog-mode-hook (lambda () (focus-mode 1)))
  )

(defun normal-coding ()
  (interactive)
  (set-face-attribute 'default nil :font "Hack-14")
  (add-hook 'prog-mode-hook 'command-log-mode)
  ;;(add-hook 'prog-mode-hook (lambda () (focus-mode 1)))
  )

(eval-after-load "org-indent" '(diminish 'org-indent-mode))

;;   (use-package all-the-icons
;;     :ensure t)

;; http://stackoverflow.com/questions/11679700/emacs-disable-beep-when-trying-to-move-beyond-the-end-of-the-document
(defun my-bell-function ())

(setq ring-bell-function 'my-bell-function)
(setq visible-bell nil)

;; ;;; Setup perspectives, or workspaces, to switch between
;; (use-package perspective
;;   :ensure t
;;   :config
;;   ;; Enable perspective mode
;;   (persp-mode t)
;;   (defmacro custom-persp (name &rest body)
;;     `(let ((initialize (not (gethash ,name perspectives-hash)))
;;            (current-perspective persp-curr))
;;        (persp-switch ,name)
;;        (when initialize ,@body)
;;        (setq persp-last current-perspective)))

;;   ;; Jump to last perspective
;;   (defun custom-persp-last ()
;;     (interactive)
;;     (persp-switch (persp-name persp-last)))

;;   (define-key persp-mode-map (kbd "C-x p -") 'custom-persp-last)

;;   (defun custom-persp/emacs ()
;;     (interactive)
;;     (custom-persp "emacs"
;;                   (find-file (concat init-dir "init.el"))))

;;   (define-key persp-mode-map (kbd "C-x p e") 'custom-persp/emacs)

;;   (defun custom-persp/qttt ()
;;     (interactive)
;;     (custom-persp "qttt"
;;                   (find-file "/Users/arjen/BuildFunThings/Projects/Clojure/Game/qttt/project.clj")))

;;   (define-key persp-mode-map (kbd "C-x p q") 'custom-persp/qttt)

;;   (defun custom-persp/trivia ()
;;     (interactive)
;;     (custom-persp "trivia"
;;                   (find-file "/Users/arjen/BuildFunThings/Projects/Clojure/trivia/project.clj")))

;;   (define-key persp-mode-map (kbd "C-x p t") 'custom-persp/trivia)

;;   (defun custom-persp/mail ()
;;     (interactive)
;;     (custom-persp "mail"
;;                   (mu4e)))

;;   (define-key persp-mode-map (kbd "C-x p m") 'custom-persp/mail)
;;   )

(use-package request
:ensure t)

;;(add-to-list 'load-path (expand-file-name (concat init-dir "ox-leanpub")))
;;(load-library "ox-leanpub")
(add-to-list 'load-path (expand-file-name (concat init-dir "ox-ghost")))
(load-library "ox-ghost")
;;; http://www.lakshminp.com/publishing-book-using-org-mode

;;(defun leanpub-export ()
;;  "Export buffer to a Leanpub book."
;;  (interactive)
;;  (if (file-exists-p "./Book.txt")
;;      (delete-file "./Book.txt"))
;;  (if (file-exists-p "./Sample.txt")
;;      (delete-file "./Sample.txt"))
;;  (org-map-entries
;;   (lambda ()
;;     (let* ((level (nth 1 (org-heading-components)))
;;            (tags (org-get-tags))
;;            (title (or (nth 4 (org-heading-components)) ""))
;;            (book-slug (org-entry-get (point) "TITLE"))
;;            (filename
;;             (or (org-entry-get (point) "EXPORT_FILE_NAME") (concat (replace-regexp-in-string " " "-" (downcase title)) ".md"))))
;;       (when (= level 1) ;; export only first level entries
;;         ;; add to Sample book if "sample" tag is found.
;;         (when (or (member "sample" tags)
;;                   ;;(string-prefix-p "frontmatter" filename) (string-prefix-p "mainmatter" filename)
;;                   )
;;           (append-to-file (concat filename "\n\n") nil "./Sample.txt"))
;;         (append-to-file (concat filename "\n\n") nil "./Book.txt")
;;         ;; set filename only if the property is missing
;;         (or (org-entry-get (point) "EXPORT_FILE_NAME")  (org-entry-put (point) "EXPORT_FILE_NAME" filename))
;;         (org-leanpub-export-to-markdown nil 1 nil)))) "-noexport")
;;  (org-save-all-org-buffers)
;;  nil
;;  nil)
;;
;;(require 'request)
;;
;;(defun leanpub-preview ()
;;  "Generate a preview of your book @ Leanpub."
;;  (interactive)
;;  (request
;;   "https://leanpub.com/clojure-on-the-server/preview.json" ;; or better yet, get the book slug from the buffer
;;   :type "POST"                                             ;; and construct the URL
;;   :data '(("api_key" . ""))
;;   :parser 'json-read
;;   :success (function*
;;             (lambda (&key data &allow-other-keys)
;;               (message "Preview generation queued at leanpub.com.")))))

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda ()
                   (flyspell-mode 1)
                   (visual-line-mode  1))))

(use-package markdown-mode
:ensure t)

(use-package htmlize
:ensure t)

(defun my/with-theme (theme fn &rest args)
  (let ((current-themes custom-enabled-themes))
    (mapcar #'disable-theme custom-enabled-themes)
    (load-theme theme t)
    (let ((result (apply fn args)))
      (mapcar #'disable-theme custom-enabled-themes)
      (mapcar (lambda (theme) (load-theme theme t)) current-themes)
      result)))
;;(advice-add #'org-export-to-file :around (apply-partially #'my/with-theme 'arjen-grey))
;;(advice-add #'org-export-to-buffer :around (apply-partially #'my/with-theme 'arjen-grey))

(use-package mode-icons
  :ensure t
  :config
  (mode-icons-mode t)
)

;;  (use-package spaceline
;;    :ensure t
;;    :init
;;    (setq powerline-default-separator 'utf-8)
;;
;;    :config
;;    (require 'spaceline-config)
;;    (spaceline-spacemacs-theme)
;;    )

(use-package f
    :ensure t)

  (use-package projectile
    :ensure t
    :config
    (add-hook 'prog-mode-hook 'projectile-mode))

(use-package powerline
    :ensure t
    :config
    (defvar mode-line-height 30 "A little bit taller, a little bit baller.")

    (defvar mode-line-bar          (eval-when-compile (pl/percent-xpm mode-line-height 100 0 100 0 3 "#909fab" nil)))
    (defvar mode-line-eldoc-bar    (eval-when-compile (pl/percent-xpm mode-line-height 100 0 100 0 3 "#B3EF00" nil)))
    (defvar mode-line-inactive-bar (eval-when-compile (pl/percent-xpm mode-line-height 100 0 100 0 3 "#9091AB" nil)))

    ;; Custom faces
    (defface mode-line-is-modified nil
      "Face for mode-line modified symbol")

    (defface mode-line-2 nil
      "The alternate color for mode-line text.")

    (defface mode-line-highlight nil
      "Face for bright segments of the mode-line.")

    (defface mode-line-count-face nil
      "Face for anzu/evil-substitute/evil-search number-of-matches display.")

    ;; Git/VCS segment faces
    (defface mode-line-vcs-info '((t (:inherit warning)))
      "")
    (defface mode-line-vcs-warning '((t (:inherit warning)))
      "")

    ;; Flycheck segment faces
    (defface doom-flycheck-error '((t (:inherit error)))
      "Face for flycheck error feedback in the modeline.")
    (defface doom-flycheck-warning '((t (:inherit warning)))
      "Face for flycheck warning feedback in the modeline.")


    (defun doom-ml-flycheck-count (state)
      "Return flycheck information for the given error type STATE."
      (when (flycheck-has-current-errors-p state)
        (if (eq 'running flycheck-last-status-change)
            "?"
          (cdr-safe (assq state (flycheck-count-errors flycheck-current-errors))))))

    (defun doom-fix-unicode (font &rest chars)
      "Display certain unicode characters in a specific font.
  e.g. (doom-fix-unicode \"DejaVu Sans\" ?⚠ ?★ ?λ)"
      (declare (indent 1))
      (mapc (lambda (x) (set-fontset-font
                    t (cons x x)
                    (cond ((fontp font)
                           font)
                          ((listp font)
                           (font-spec :family (car font) :size (nth 1 font)))
                          ((stringp font)
                           (font-spec :family font))
                          (t (error "FONT is an invalid type: %s" font)))))
            chars))

    ;; Make certain unicode glyphs bigger for the mode-line.
    ;; FIXME Replace with all-the-icons?
    (doom-fix-unicode '("DejaVu Sans Mono" 15) ?✱) ;; modified symbol
    (let ((font "DejaVu Sans Mono for Powerline")) ;;
      (doom-fix-unicode (list font 12) ?)  ;; git symbol
      (doom-fix-unicode (list font 16) ?∄)  ;; non-existent-file symbol
      (doom-fix-unicode (list font 15) ?)) ;; read-only symbol

    ;; So the mode-line can keep track of "the current window"
    (defvar mode-line-selected-window nil)
    (defun doom|set-selected-window (&rest _)
      (let ((window (frame-selected-window)))
        (when (and (windowp window)
                   (not (minibuffer-window-active-p window)))
          (setq mode-line-selected-window window))))
    (add-hook 'window-configuration-change-hook #'doom|set-selected-window)
    (add-hook 'focus-in-hook #'doom|set-selected-window)
    (advice-add 'select-window :after 'doom|set-selected-window)
    (advice-add 'select-frame  :after 'doom|set-selected-window)

    (defun doom/project-root (&optional strict-p)
      "Get the path to the root of your project."
      (let (projectile-require-project-root strict-p)
        (projectile-project-root)))

    (defun *buffer-path ()
      "Displays the buffer's full path relative to the project root (includes the
  project root). Excludes the file basename. See `*buffer-name' for that."
      (when buffer-file-name
        (propertize
         (f-dirname
          (let ((buffer-path (file-relative-name buffer-file-name (doom/project-root)))
                (max-length (truncate (/ (window-body-width) 1.75))))
            (concat (projectile-project-name) "/"
                    (if (> (length buffer-path) max-length)
                        (let ((path (reverse (split-string buffer-path "/" t)))
                              (output ""))
                          (when (and path (equal "" (car path)))
                            (setq path (cdr path)))
                          (while (and path (<= (length output) (- max-length 4)))
                            (setq output (concat (car path) "/" output))
                            (setq path (cdr path)))
                          (when path
                            (setq output (concat "../" output)))
                          (when (string-suffix-p "/" output)
                            (setq output (substring output 0 -1)))
                          output)
                      buffer-path))))
         'face (if active 'mode-line-2))))

    (defun *buffer-name ()
      "The buffer's base name or id."
      ;; FIXME Don't show uniquify tags
      (s-trim-left (format-mode-line "%b")))

    (defun *buffer-pwd ()
      "Displays `default-directory', for special buffers like the scratch buffer."
      (propertize
       (concat "[" (abbreviate-file-name default-directory) "]")
       'face 'mode-line-2))

    (defun *buffer-state ()
      "Displays symbols representing the buffer's state (non-existent/modified/read-only)"
      (when buffer-file-name
        (propertize
         (concat (if (not (file-exists-p buffer-file-name))
                     "∄"
                   (if (buffer-modified-p) "✱"))
                 (if buffer-read-only ""))
         'face 'mode-line-is-modified)))

    (defun *buffer-encoding-abbrev ()
      "The line ending convention used in the buffer."
      (if (memq buffer-file-coding-system '(utf-8 utf-8-unix))
          ""
        (symbol-name buffer-file-coding-system)))

    (defun *major-mode ()
      "The major mode, including process, environment and text-scale info."
      (concat (format-mode-line mode-name)
              (if (stringp mode-line-process) mode-line-process)
              (and (featurep 'face-remap)
                   (/= text-scale-mode-amount 0)
                   (format " (%+d)" text-scale-mode-amount))))

    (defun *vc ()
      "Displays the current branch, colored based on its state."
      (when vc-mode
        (let ((backend (concat " " (substring vc-mode (+ 2 (length (symbol-name (vc-backend buffer-file-name)))))))
              (face (let ((state (vc-state buffer-file-name)))
                      (cond ((memq state '(edited added))
                             'mode-line-vcs-info)
                            ((memq state '(removed needs-merge needs-update conflict removed unregistered))
                             'mode-line-vcs-warning)))))
          (if active
              (propertize backend 'face face)
            backend))))

    (defvar-local doom--flycheck-err-cache nil "")
    (defvar-local doom--flycheck-cache nil "")
    (defun *flycheck ()
      "Persistent and cached flycheck indicators in the mode-line."
      (when (and (featurep 'flycheck)
                 flycheck-mode
                 (or flycheck-current-errors
                     (eq 'running flycheck-last-status-change)))
        (or (and (or (eq doom--flycheck-err-cache doom--flycheck-cache)
                     (memq flycheck-last-status-change '(running not-checked)))
                 doom--flycheck-cache)
            (and (setq doom--flycheck-err-cache flycheck-current-errors)
                 (setq doom--flycheck-cache
                       (let ((fe (doom-ml-flycheck-count 'error))
                             (fw (doom-ml-flycheck-count 'warning)))
                         (concat
                          (if fe (propertize (format " •%d " fe)
                                             'face (if active
                                                       'doom-flycheck-error
                                                     'mode-line)))
                          (if fw (propertize (format " •%d " fw)
                                             'face (if active
                                                       'doom-flycheck-warning
                                                     'mode-line))))))))))

    (defun *buffer-position ()
      "A more vim-like buffer position."
      (let ((start (window-start))
            (end (window-end))
            (pend (point-max)))
        (if (and (= start 1)
                 (= end pend))
            ":All"
          (cond ((= start 1) ":Top")
                ((= end pend) ":Bot")
                (t (format ":%d%%%%" (/ end 0.01 pend)))))))

    (defun my-mode-line (&optional id)
      `(:eval
        (let* ((active (eq (selected-window) mode-line-selected-window))
               (lhs (list (propertize " " 'display (if active mode-line-bar mode-line-inactive-bar))
                          (*flycheck)
                          " "
                          (*buffer-path)
                          (*buffer-name)
                          " "
                          (*buffer-state)
                          ,(if (eq id 'scratch) '(*buffer-pwd))))
               (rhs (list (*buffer-encoding-abbrev) "  "
                          (*vc)
;;                          " "
;;                          (when persp-curr persp-modestring)
                          " " (*major-mode) "  "
                          (propertize
                           (concat "(%l,%c) " (*buffer-position))
                           'face (if active 'mode-line-2))))
               (middle (propertize
                        " " 'display `((space :align-to (- (+ right right-fringe right-margin)
                                                           ,(1+ (string-width (format-mode-line rhs)))))))))
          (list lhs middle rhs))))

    (setq-default mode-line-format (my-mode-line)))

(use-package pass
:ensure t)

(use-package auth-password-store
  :ensure t
  :config
  (auth-pass-enable))
