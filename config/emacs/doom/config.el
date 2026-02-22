;;; config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))

(setq doom-font (font-spec :family "CaskaydiaCoveNerdFont" :size 13 :weight 'regular)
      doom-variable-pitch-font (font-spec :family "Atkinson Hyperlegible Next" :size 14))

;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Disable backups and auto-saves (ephemeral system)
(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil)

;; Org Mode: variable-pitch, fonts, and fixed-pitch for code
(after! org
  ;; Use variable-pitch-mode in org buffers, then re-pin line numbers to fixed-pitch
  (add-hook 'org-mode-hook 'variable-pitch-mode)
  (add-hook 'org-mode-hook
            (lambda ()
              (face-remap-add-relative 'line-number :font "CaskaydiaCoveNerdFont")
              (face-remap-add-relative 'line-number-current-line :font "CaskaydiaCoveNerdFont")))

  ;; Resize headings and use variable-pitch font for them
  (dolist (face '((org-level-1 . 1.35)
                  (org-level-2 . 1.3)
                  (org-level-3 . 1.2)
                  (org-level-4 . 1.1)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil
                        :font "Atkinson Hyperlegible Next"
                        :weight 'bold
                        :height (cdr face)))

  ;; Make the document title a bit bigger
  (set-face-attribute 'org-document-title nil
                      :font "Atkinson Hyperlegible Next"
                      :weight 'bold
                      :height 1.8)

  ;; Ensure org-indent inherits fixed-pitch to avoid spacing issues
  (require 'org-indent)
  (set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))

  ;; Keep code blocks, verbatim, etc. in fixed-pitch
  (set-face-attribute 'org-block nil           :foreground 'unspecified :inherit 'fixed-pitch :height 0.85)
  (set-face-attribute 'org-code nil            :inherit '(shadow fixed-pitch) :height 0.85)
  (set-face-attribute 'org-indent nil          :inherit '(org-hide fixed-pitch) :height 0.85)
  (set-face-attribute 'org-verbatim nil        :inherit '(shadow fixed-pitch) :height 0.85)
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil       :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil        :inherit 'fixed-pitch)

  ;; Decluttering & Text Prettification
  (setq org-adapt-indentation t
        org-hide-leading-stars t
        org-hide-emphasis-markers t
        org-pretty-entities t
        org-ellipsis " […]")

  (set-face-attribute 'org-ellipsis nil :foreground "#9AA3AD" :underline nil)

  ;; Source code block settings
  (setq org-src-fontify-natively t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 0)

  ;; Line wrapping
  (add-hook 'org-mode-hook 'visual-line-mode)

  ;; Task & Time Tracking: open selection menu instead of cycling
  (setq org-use-fast-todo-selection t)

  ;; Make the TODO keyword in headings smaller
  (set-face-attribute 'org-todo nil :height 0.85)

  ;; Task & Time Tracking: priorities
  (setq org-lowest-priority ?F)  ;; Gives us priorities A through F
  (setq org-default-priority ?E) ;; If an item has no priority, it is considered [#E].
  (setq org-priority-faces
        '((65 . "#BF616A")
          (66 . "#EBCB8B")
          (67 . "#B48EAD")
          (68 . "#81A1C1")
          (69 . "#5E81AC")
          (70 . "#4C566A")))

  ;; Task & Time Tracking: keywords and colours
  (setq org-todo-keywords
        '((sequence
           "TODO" "PROJ" "READ" "CHECK" "IDEA" ; Needs further action
           "|"
           "DONE")))                           ; Needs no action currently
  (setq org-todo-keyword-faces
        '(("TODO"  :inherit (org-todo region) :foreground "#A3BE8C" :weight bold)
          ("STRD"  :inherit (org-todo region) :foreground "#88C0D0" :weight bold)
          ("FINL"  :inherit (org-todo region) :foreground "#8FBCBB" :weight bold)
          ("CHECK" :inherit (org-todo region) :foreground "#81A1C1" :weight bold)
          ("IDEA"  :inherit (org-todo region) :foreground "#EBCB8B" :weight bold)
          ("DONE"  :inherit (org-todo region) :foreground "#30343d" :weight bold))))

;; Prettier UI Elements: org-modern
(use-package! org-modern
  :after org
  :config
  (setq
   org-auto-align-tags t
   org-tags-column 0
   org-fold-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t
   ;; Don't style the following
   org-modern-tag nil
   org-modern-priority nil
   org-modern-todo nil
   org-modern-table nil
   ;; Agenda styling
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
     (800 1000 1200 1400 1600 1800 2000)
     " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "⭠ now ─────────────────────────────────────────────────")
  (global-org-modern-mode))
