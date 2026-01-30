;; Emacs minibuffer configurations.
(use-package emacs
  :init
  ;; No startup message
  (setq inhibit-startup-message t
        inhibit-startup-echo-area-message "hgl")

  ;; No message in scratch buffer
  (setq initial-scratch-message nil)

  ;; Initial buffer
  (setq initial-buffer-choice nil)

  ;; No frame title
  ;; (setq frame-title-format nil)

  ;; No scroll bars
  (if (fboundp 'scroll-bar-mode) (set-scroll-bar-mode nil))

  ;; No toolbar
  (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))

  ;; No menu bar
  ;; (if (display-graphic-p)
  ;;    (menu-bar-mode t) ;; When nil, focus problem on OSX
  ;;  (menu-bar-mode -1))

  ;; Text mode is initial mode
  (setq initial-major-mode 'text-mode)

  ;; Text mode is default major mode
  (setq default-major-mode 'text-mode)

  ;; Mac specific
  (when (eq system-type 'darwin)
    (setq ns-use-native-fullscreen t
          mac-command-modifier 'meta
          mac-use-title-bar t))

  (server-start)
  (setq server-client-instructions nil)

  :bind (
    ("M-q" . save-buffers-kill-terminal)
    ("M-c" . kill-ring-save)
    ("M-x" . ses-kill-override)
    ("M-v" . clipboard-yank)
    ("M-w" . kill-current-buffer)
    ("M-s" . save-buffer)
    :map minibuffer-local-map
    ("<escape>" . keyboard-escape-quit)
    :map minibuffer-local-ns-map
    ("<escape>" . keyboard-escape-quit)
    :map minibuffer-local-completion-map
    ("<escape>" . keyboard-escape-quit)
    :map minibuffer-local-must-match-map
    ("<escape>" . keyboard-escape-quit)
    :map minibuffer-local-isearch-map
    ("<escape>" . keyboard-escape-quit))

  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package hel
  :custom
  (hel-want-minibuffer nil)
  :config
  (hel-mode)
  (hel-keymap-global-set :state 'normal
    "<SPC> <SPC>" 'async-shell-command
    "<SPC> h f" 'describe-function
    "<SPC> h v" 'describe-variable
    "<SPC> h c" 'describe-char
    "<SPC> h k" 'describe-key
    "<SPC> h m" 'describe-mode
    "<SPC> p p" 'project-find-file
    "<SPC> p c" 'project-compile
    "<SPC> g g" 'magit
    "<SPC> b b" 'consult-buffer
    "<SPC> w q" 'kill-buffer-and-window
    "<SPC> w 1" 'delete-other-windows))

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(use-package vertico-directory
  :after vertico
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package magit)

(use-package forge
  :after magit)

;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
         ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package typescript-ts-mode
  :mode "\\.ts\\'")

(use-package tsx-ts-mode
  :mode "\\.tsx\\'")

(use-package js-ts-mode
  :mode "\\.js\\'")

(use-package eglot
  :hook ((nix-mode tsx-ts-mode typescript-ts-mode js-ts-mode) . eglot-ensure))

(use-package corfu
  ;; Optional customizations
  :custom
  (corfu-auto t)
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  :init

  ;; Recommended: Enable Corfu globally.  Recommended since many modes provide
  ;; Capfs and Dabbrev can be used globally (M-/).  See also the customization
  ;; variable `global-corfu-modes' to exclude certain modes.
  (global-corfu-mode)

  ;; Enable optional extension modes:
  ;; (corfu-history-mode)
  ;; (corfu-popupinfo-mode)
  )

(use-package consult
  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
)

(use-package elec-pair
  :config
  (electric-pair-mode +1))

(use-package doom-themes
  :ensure t
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; for treemacs users
  (doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
  :config
  (load-theme 'doom-nord t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package which-key
  :config
  (which-key-mode))

(use-package doom-modeline
  :init (doom-modeline-mode 1))
