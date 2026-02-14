;;; init.el --- Emacs initialization file -*- lexical-binding: t; -*-

;;; Commentary:
;; This is the main Emacs configuration file.
;; All configuration is managed declaratively through Nix.
;; Everything is ephemeral and regenerated on reboot.

;;; Code:

;; Basic settings
(setq inhibit-startup-message t)
(setq initial-scratch-message nil)

;; UI improvements
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(show-paren-mode 1)
(global-display-line-numbers-mode 1)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Better defaults
(setq-default
 indent-tabs-mode nil
 tab-width 4
 fill-column 80)

;; Disable backups and auto-saves (fully ephemeral system)
(setq make-backup-files nil)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil)
(setq create-lockfiles nil)

;; Enable recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
;; Don't save recentf across reboots (ephemeral)
(setq recentf-auto-cleanup 'never)

;; Enable auto-revert for files changed on disk
(global-auto-revert-mode 1)

;; Smooth scrolling
(setq scroll-conservatively 101)
(setq scroll-margin 3)

;; Better handling of long lines
(global-so-long-mode 1)

;; UTF-8 encoding
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;; Disable custom file (not needed in declarative config)
(setq custom-file (make-temp-file "emacs-custom-"))

;;; Package Configuration

;; Evil mode (Vim keybindings)
(require 'evil)
(setq evil-want-integration t)
(setq evil-want-keybinding nil)
(evil-mode 1)
(require 'evil-collection)
(evil-collection-init)

;; Which-key for keybinding hints
(require 'which-key)
(which-key-mode 1)
(setq which-key-idle-delay 0.3)

;; Doom themes
(require 'doom-themes)
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)
(load-theme 'doom-one t)
(doom-themes-visual-bell-config)
(doom-themes-org-config)

;; Doom modeline
(require 'doom-modeline)
(doom-modeline-mode 1)
(setq doom-modeline-height 25)

;; Vertico - vertical completion
(require 'vertico)
(vertico-mode 1)

;; Marginalia - rich annotations
(require 'marginalia)
(marginalia-mode 1)

;; Orderless - flexible completion
(require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      completion-category-overrides '((file (styles partial-completion))))

;; Consult - useful commands
(require 'consult)
;; Keybindings for consult
(global-set-key (kbd "C-s") 'consult-line)
(global-set-key (kbd "C-x b") 'consult-buffer)

;; Embark - context actions
(require 'embark)
(require 'embark-consult)
(global-set-key (kbd "C-.") 'embark-act)

;; Company - code completion
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 0.2
      company-minimum-prefix-length 1)

;; Rainbow delimiters
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

;; Undo tree
(require 'undo-tree)
(global-undo-tree-mode 1)
(setq undo-tree-auto-save-history nil) ; Don't save history (ephemeral)

;; Projectile - project management
(require 'projectile)
(projectile-mode 1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; Magit - Git interface
(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)

;; Flycheck - syntax checking
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Nix mode
(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

;; Markdown mode
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

;; YAML mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-mode))

;; JSON mode
(require 'json-mode)
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-mode))

;; Org bullets
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(provide 'init)
;;; init.el ends here
