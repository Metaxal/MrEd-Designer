#lang racket/gui

;;==========================================================================
;;===                Code generated with MrEd Designer 3.0               ===
;;===                 https://github.com/Metaxal/MrEd-Designer           ===
;;==========================================================================

;;; Call (mred-designer-init) with optional arguments to this module

(require
 framework
 )

(provide)

(define (label-bitmap-proc l)
  (let ((label (first l)) (image? (second l)) (file (third l)))
    (or (and image?
             (or (and file
                      (let ((bmp (make-object bitmap% file)))
                        (and (send bmp ok?) bmp)))
                 "<Bad Image>"))
        label)))

(define (list->font l) (send/apply the-font-list find-or-create-font l))

(define frame-toolbox #f)
(define vertical-panel-5143 #f)
(define group-box-panel-containers #f)
(define button-5192 #f)
(define group-box-panel-controls #f)
(define button-5282 #f)
(define group-box-panel-menu #f)
(define button-5290 #f)
(define group-box-panel-templates #f)
(define horizontal-panel-5381 #f)
(define choice-5385 #f)
(define button-template-insert #f)
(define horizontal-panel-5514 #f)
(define button-template-save #f)
(define button-template-replace #f)
(define button-template-delete #f)
(define group-box-panel-generate-code #f)
(define horizontal-panel-5941 #f)
(define button-console #f)
(define button-code-file #f)
(define menu-bar-99582 #f)
(define menu-file #f)
(define menu-item-open #f)
(define menu-item-save #f)
(define menu-item-save-as #f)
(define separator-menu-item-99622 #f)
(define menu-item-exit #f)
(define menu-edit #f)
(define menu-item-cut #f)
(define menu-item-copy #f)
(define menu-item-paste #f)
(define separator-menu-item-99686 #f)
(define menu-item-pref #f)
(define menu-windows #f)
(define menu-item-windows-properties #f)
(define menu-item-5901 #f)
(define menu-help #f)
(define menu-item-about #f)
(define frame-hierarchy #f)
(define horizontal-panel-6948 #f)
(define button-hierarchy-delete #f)
(define button-hierarchy-cut #f)
(define button-hierarchy-copy #f)
(define button-hierarchy-paste #f)
(define button-hierarchy-up #f)
(define button-hierarchy-down #f)
(define canvas-9346 #f)
(define (mred-designer-init
         #:button-5192-callback
         (button-5192-callback (lambda (button control-event) (void)))
         #:button-5282-callback
         (button-5282-callback (lambda (button control-event) (void)))
         #:button-5290-callback
         (button-5290-callback (lambda (button control-event) (void)))
         #:choice-5385-callback
         (choice-5385-callback (lambda (choice control-event) (void)))
         #:button-template-insert-callback
         (button-template-insert-callback
          (lambda (button control-event) (void)))
         #:button-template-save-callback
         (button-template-save-callback (lambda (button control-event) (void)))
         #:button-template-replace-callback
         (button-template-replace-callback
          (lambda (button control-event) (void)))
         #:button-template-delete-callback
         (button-template-delete-callback
          (lambda (button control-event) (void)))
         #:button-console-callback
         (button-console-callback (lambda (button control-event) (void)))
         #:button-code-file-callback
         (button-code-file-callback (lambda (button control-event) (void)))
         #:menu-bar-99582-demand-callback
         (menu-bar-99582-demand-callback (lambda (m) (void)))
         #:menu-file-demand-callback
         (menu-file-demand-callback (lambda (m) (void)))
         #:menu-item-open-callback
         (menu-item-open-callback (lambda (item event) (void)))
         #:menu-item-open-demand-callback
         (menu-item-open-demand-callback (lambda (item) (void)))
         #:menu-item-save-callback
         (menu-item-save-callback (lambda (item event) (void)))
         #:menu-item-save-demand-callback
         (menu-item-save-demand-callback (lambda (item) (void)))
         #:menu-item-save-as-callback
         (menu-item-save-as-callback (lambda (item event) (void)))
         #:menu-item-save-as-demand-callback
         (menu-item-save-as-demand-callback (lambda (item) (void)))
         #:menu-item-exit-callback
         (menu-item-exit-callback (lambda (item event) (void)))
         #:menu-item-exit-demand-callback
         (menu-item-exit-demand-callback (lambda (item) (void)))
         #:menu-edit-demand-callback
         (menu-edit-demand-callback (lambda (m) (void)))
         #:menu-item-cut-callback
         (menu-item-cut-callback (lambda (item event) (void)))
         #:menu-item-cut-demand-callback
         (menu-item-cut-demand-callback (lambda (item) (void)))
         #:menu-item-copy-callback
         (menu-item-copy-callback (lambda (item event) (void)))
         #:menu-item-copy-demand-callback
         (menu-item-copy-demand-callback (lambda (item) (void)))
         #:menu-item-paste-callback
         (menu-item-paste-callback (lambda (item event) (void)))
         #:menu-item-paste-demand-callback
         (menu-item-paste-demand-callback (lambda (item) (void)))
         #:menu-item-pref-callback
         (menu-item-pref-callback (lambda (item event) (void)))
         #:menu-item-pref-demand-callback
         (menu-item-pref-demand-callback (lambda (item) (void)))
         #:menu-windows-demand-callback
         (menu-windows-demand-callback (lambda (m) (void)))
         #:menu-item-windows-properties-callback
         (menu-item-windows-properties-callback (lambda (item event) (void)))
         #:menu-item-windows-properties-demand-callback
         (menu-item-windows-properties-demand-callback (lambda (item) (void)))
         #:menu-item-5901-callback
         (menu-item-5901-callback (lambda (item event) (void)))
         #:menu-item-5901-demand-callback
         (menu-item-5901-demand-callback (lambda (item) (void)))
         #:menu-help-demand-callback
         (menu-help-demand-callback (lambda (m) (void)))
         #:menu-item-about-callback
         (menu-item-about-callback (lambda (item event) (void)))
         #:menu-item-about-demand-callback
         (menu-item-about-demand-callback (lambda (item) (void)))
         #:button-hierarchy-delete-callback
         (button-hierarchy-delete-callback
          (lambda (button control-event) (void)))
         #:button-hierarchy-cut-callback
         (button-hierarchy-cut-callback (lambda (button control-event) (void)))
         #:button-hierarchy-copy-callback
         (button-hierarchy-copy-callback
          (lambda (button control-event) (void)))
         #:button-hierarchy-paste-callback
         (button-hierarchy-paste-callback
          (lambda (button control-event) (void)))
         #:button-hierarchy-up-callback
         (button-hierarchy-up-callback (lambda (button control-event) (void)))
         #:button-hierarchy-down-callback
         (button-hierarchy-down-callback
          (lambda (button control-event) (void)))
         #:canvas-9346-paint-callback
         (canvas-9346-paint-callback (lambda (canvas dc) (void))))
  (set! frame-toolbox
    (new
     frame%
     (parent #f)
     (label "MrEd Designer")
     (width 421)
     (height 338)
     (x 451)
     (y 18)
     (style '())
     (enabled #t)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'top))
     (min-width 70)
     (min-height 30)
     (stretchable-width #t)
     (stretchable-height #t)))
  (set! vertical-panel-5143
    (new
     vertical-panel%
     (parent frame-toolbox)
     (style '())
     (enabled #t)
     (vert-margin 0)
     (horiz-margin 0)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'top))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #t)))
  (set! group-box-panel-containers
    (new
     group-box-panel%
     (parent vertical-panel-5143)
     (label "Containers")
     (style '())
     (font
      (list->font (list 8 "Arial" 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (border 0)
     (spacing 0)
     (alignment (list 'left 'top))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! button-5192
    (new
     button%
     (parent group-box-panel-containers)
     (label
      (label-bitmap-proc
       (list
        "Button"
        #t
        "E:\\Projets\\Scheme\\mred-designer\\widgets\\frame\\icons\\24x24.png")))
     (callback button-5192-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! group-box-panel-controls
    (new
     group-box-panel%
     (parent vertical-panel-5143)
     (label "Controls")
     (style '())
     (font
      (list->font (list 8 "Arial" 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (border 0)
     (spacing 0)
     (alignment (list 'left 'top))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! button-5282
    (new
     button%
     (parent group-box-panel-controls)
     (label
      (label-bitmap-proc
       (list
        "Button"
        #t
        "E:\\Projets\\Scheme\\mred-designer\\widgets\\button\\icons\\24x24.png")))
     (callback button-5282-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! group-box-panel-menu
    (new
     group-box-panel%
     (parent vertical-panel-5143)
     (label "Menu")
     (style '())
     (font
      (list->font (list 8 "Arial" 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (border 0)
     (spacing 0)
     (alignment (list 'left 'top))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! button-5290
    (new
     button%
     (parent group-box-panel-menu)
     (label
      (label-bitmap-proc
       (list
        "Button"
        #t
        "E:\\Projets\\Scheme\\mred-designer\\widgets\\menu\\icons\\24x24.png")))
     (callback button-5290-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! group-box-panel-templates
    (new
     group-box-panel%
     (parent vertical-panel-5143)
     (label "Templates")
     (style '())
     (font
      (list->font (list 8 "Arial" 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'top))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! horizontal-panel-5381
    (new
     horizontal-panel%
     (parent group-box-panel-templates)
     (style '())
     (enabled #t)
     (vert-margin 0)
     (horiz-margin 0)
     (border 0)
     (spacing 0)
     (alignment (list 'left 'center))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #t)))
  (set! choice-5385
    (new
     choice%
     (parent horizontal-panel-5381)
     (label "")
     (choices (list "First" "Second"))
     (callback choice-5385-callback)
     (style
      ((lambda (l) (list* (first l) (second l))) (list 'horizontal-label '())))
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (selection 0)
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! button-template-insert
    (new
     button%
     (parent horizontal-panel-5381)
     (label (label-bitmap-proc (list "Insert" #f #f)))
     (callback button-template-insert-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! horizontal-panel-5514
    (new
     horizontal-panel%
     (parent group-box-panel-templates)
     (style '())
     (enabled #t)
     (vert-margin 0)
     (horiz-margin 0)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'center))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #t)))
  (set! button-template-save
    (new
     button%
     (parent horizontal-panel-5514)
     (label (label-bitmap-proc (list "Save" #f #f)))
     (callback button-template-save-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-template-replace
    (new
     button%
     (parent horizontal-panel-5514)
     (label (label-bitmap-proc (list "Replace" #f #f)))
     (callback button-template-replace-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-template-delete
    (new
     button%
     (parent horizontal-panel-5514)
     (label (label-bitmap-proc (list "Delete" #f #f)))
     (callback button-template-delete-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! group-box-panel-generate-code
    (new
     group-box-panel%
     (parent vertical-panel-5143)
     (label "Generate code...")
     (style '())
     (font
      (list->font (list 8 "Arial" 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'top))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! horizontal-panel-5941
    (new
     horizontal-panel%
     (parent group-box-panel-generate-code)
     (style '())
     (enabled #t)
     (vert-margin 0)
     (horiz-margin 0)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'center))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #t)))
  (set! button-console
    (new
     button%
     (parent horizontal-panel-5941)
     (label (label-bitmap-proc (list "To console" #f #f)))
     (callback button-console-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 110)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-code-file
    (new
     button%
     (parent horizontal-panel-5941)
     (label (label-bitmap-proc (list "To file..." #f #f)))
     (callback button-code-file-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 110)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! menu-bar-99582
    (new
     menu-bar%
     (parent frame-toolbox)
     (demand-callback menu-bar-99582-demand-callback)))
  (set! menu-file
    (new
     menu%
     (parent menu-bar-99582)
     (label "&File")
     (help-string "File")
     (demand-callback menu-file-demand-callback)))
  (set! menu-item-open
    (new
     menu-item%
     (parent menu-file)
     (label "&Open...")
     (callback menu-item-open-callback)
     (shortcut #\O)
     (help-string "Open")
     (demand-callback menu-item-open-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-item-save
    (new
     menu-item%
     (parent menu-file)
     (label "&Save")
     (callback menu-item-save-callback)
     (shortcut #\S)
     (help-string "Save")
     (demand-callback menu-item-save-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-item-save-as
    (new
     menu-item%
     (parent menu-file)
     (label "&Save as...")
     (callback menu-item-save-as-callback)
     (shortcut #f)
     (help-string "Save as")
     (demand-callback menu-item-save-as-demand-callback)
     (shortcut-prefix '(ctl shift))))
  (set! separator-menu-item-99622
    (new separator-menu-item% (parent menu-file)))
  (set! menu-item-exit
    (new
     menu-item%
     (parent menu-file)
     (label "E&xit")
     (callback menu-item-exit-callback)
     (shortcut #\Q)
     (help-string "Exit Application")
     (demand-callback menu-item-exit-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-edit
    (new
     menu%
     (parent menu-bar-99582)
     (label "&Edit")
     (help-string "Edit")
     (demand-callback menu-edit-demand-callback)))
  (set! menu-item-cut
    (new
     menu-item%
     (parent menu-edit)
     (label "&Cut")
     (callback menu-item-cut-callback)
     (shortcut #\X)
     (help-string "Cut")
     (demand-callback menu-item-cut-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-item-copy
    (new
     menu-item%
     (parent menu-edit)
     (label "&Copy")
     (callback menu-item-copy-callback)
     (shortcut #\C)
     (help-string "Copy")
     (demand-callback menu-item-copy-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-item-paste
    (new
     menu-item%
     (parent menu-edit)
     (label "&Paste")
     (callback menu-item-paste-callback)
     (shortcut #\V)
     (help-string "Paste")
     (demand-callback menu-item-paste-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! separator-menu-item-99686
    (new separator-menu-item% (parent menu-edit)))
  (set! menu-item-pref
    (new
     menu-item%
     (parent menu-edit)
     (label "&Preferences...")
     (callback menu-item-pref-callback)
     (shortcut 'f1)
     (help-string "Preferences")
     (demand-callback menu-item-pref-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-windows
    (new
     menu%
     (parent menu-bar-99582)
     (label "Windows")
     (help-string "Windows Management")
     (demand-callback menu-windows-demand-callback)))
  (set! menu-item-windows-properties
    (new
     menu-item%
     (parent menu-windows)
     (label "Show/Hide Properties")
     (callback menu-item-windows-properties-callback)
     (shortcut #f)
     (help-string "Item")
     (demand-callback menu-item-windows-properties-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-item-5901
    (new
     menu-item%
     (parent menu-windows)
     (label "Show/Hide Hierarchy")
     (callback menu-item-5901-callback)
     (shortcut #f)
     (help-string "Item")
     (demand-callback menu-item-5901-demand-callback)
     (shortcut-prefix '(ctl))))
  (set! menu-help
    (new
     menu%
     (parent menu-bar-99582)
     (label "&Help")
     (help-string "Help")
     (demand-callback menu-help-demand-callback)))
  (set! menu-item-about
    (new
     menu-item%
     (parent menu-help)
     (label "&About...")
     (callback menu-item-about-callback)
     (shortcut 'f1)
     (help-string "About")
     (demand-callback menu-item-about-demand-callback)
     (shortcut-prefix '())))
  (set! frame-hierarchy
    (new
     frame%
     (parent #f)
     (label "Hierarchy")
     (width 349)
     (height 528)
     (x 439)
     (y 389)
     (style '())
     (enabled #t)
     (border 0)
     (spacing 0)
     (alignment (list 'center 'top))
     (min-width 70)
     (min-height 30)
     (stretchable-width #t)
     (stretchable-height #t)))
  (set! horizontal-panel-6948
    (new
     horizontal-panel%
     (parent frame-hierarchy)
     (style '(border))
     (enabled #t)
     (vert-margin 0)
     (horiz-margin 0)
     (border 0)
     (spacing 0)
     (alignment (list 'left 'center))
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #f)))
  (set! button-hierarchy-delete
    (new
     button%
     (parent horizontal-panel-6948)
     (label (label-bitmap-proc (list "Delete" #f #f)))
     (callback button-hierarchy-delete-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-hierarchy-cut
    (new
     button%
     (parent horizontal-panel-6948)
     (label (label-bitmap-proc (list "Cut" #f #f)))
     (callback button-hierarchy-cut-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-hierarchy-copy
    (new
     button%
     (parent horizontal-panel-6948)
     (label (label-bitmap-proc (list "Copy" #f #f)))
     (callback button-hierarchy-copy-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-hierarchy-paste
    (new
     button%
     (parent horizontal-panel-6948)
     (label (label-bitmap-proc (list "Paste" #f #f)))
     (callback button-hierarchy-paste-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-hierarchy-up
    (new
     button%
     (parent horizontal-panel-6948)
     (label
      (label-bitmap-proc
       (list
        "Up"
        #t
        "E:\\Projets\\Scheme\\mred-designer\\images\\hierarchy-up.png")))
     (callback button-hierarchy-up-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! button-hierarchy-down
    (new
     button%
     (parent horizontal-panel-6948)
     (label
      (label-bitmap-proc
       (list
        "Down"
        #t
        "E:\\Projets\\Scheme\\mred-designer\\images\\hierarchy-down.png")))
     (callback button-hierarchy-down-callback)
     (style '())
     (font (list->font (list 8 'default 'normal 'normal #f 'default #f)))
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #f)
     (stretchable-height #f)))
  (set! canvas-9346
    (new
     canvas%
     (parent frame-hierarchy)
     (style '())
     (paint-callback canvas-9346-paint-callback)
     (label "Canvas")
     (gl-config #f)
     (enabled #t)
     (vert-margin 2)
     (horiz-margin 2)
     (min-width 0)
     (min-height 0)
     (stretchable-width #t)
     (stretchable-height #t)))
  (send frame-toolbox show #t)
  (send frame-hierarchy show #t))
