;;; init.el --- Emacs initialization file -*- lexical-binding: t; -*-

;;; Commentary:
;; This is the main Emacs configuration file.
;; All configuration is managed declaratively through Nix.

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

;; Save backup files to a dedicated directory
(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))
(setq auto-save-file-name-transforms `((".*" ,(concat user-emacs-directory "auto-save/") t)))

;; Enable recent files
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)

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

;; Load custom file if it exists (for customize interface)
(setq custom-file (concat user-emacs-directory "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))

(provide 'init)
;;; init.el ends here
