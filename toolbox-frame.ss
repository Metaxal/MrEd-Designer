#lang scheme/gui

;; ##################################################################################
;; # ============================================================================== #
;; # MrEd Designer - toolbox-frame.ss                                               #
;; # http://mreddesigner.lozi.org                                                   #
;; # Copyright (C) Lozi Jean-Pierre, 2004 - mailto:jean-pierre@lozi.org             #
;; # Copyright (C) Peter Ivanyi, 2007                                               #
;; # Copyright (C) Laurent Orseau, 2010                                             #
;; # ============================================================================== #
;; #                                                                                #
;; # This program is free software; you can redistribute it and/or                  #
;; # modify it under the terms of the GNU General Public License                    #
;; # as published by the Free Software Foundation; either version 2                 #
;; # of the License, or (at your option) any later version.                         #
;; #                                                                                #
;; # This program is distributed in the hope that it will be useful,                #
;; # but WITHOUT ANY WARRANTY; without even the implied warranty of                 #
;; # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  #
;; # GNU General Public License for more details.                                   #
;; #                                                                                #
;; # You should have received a copy of the GNU General Public License              #
;; # along with this program; if not, write to the Free Software                    #
;; # Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.    #
;; #                                                                                #
;; ##################################################################################


(require "mred-plugin.ss"
         "plugin.ss"
         "mreddesigner-misc.ss"
         "mreddesigner-help.ss"
         "tooltip.ss"
         "templates.ss"
         )

(define/provide toolbox-frame #f)
(define toolbox-frame-vertical-pane #f)
(define toolbox-plugin-button-callback #f)
(define lb-templates #f)

(define toolbox-frame%
  (class frame%
    (init-field on-close-callback)
    (super-new)
    
    (define closing? #f)
    (define/augment (on-close)
      (debug-printf "toolbox-frame%: on-close: closing:~a~n" closing?)
      (unless closing?
        (set! closing? #t)
        (on-close-callback)))
    ))

(define/provide (make-toolbox-frame 
                 ; we could use global parameters instead!
                 ; that would avoid a lot of id rewrite!
                 #:exit-application-callback exit-application-callback
                 #:plugin-button-callback    plugin-button-callback 
                 #:generate-code-callback    generate-code-callback
                 #:generate-code-to-console-callback generate-code-to-console-callback
                 #:new-project-callback      new-project-callback
                 #:load-project-callback     load-project-callback
                 #:save-project-callback     save-project-callback
                 #:close-project-callback    close-project-callback
                 #:add-template-callback     add-template-callback
                 #:save-template-callback    save-template-callback
                 #:replace-template-callback replace-template-callback
                 #:delete-template-callback  delete-template-callback
                 #:show-properties-callback  show-properties-callback
                 #:show-hierarchy-callback   show-hierarchy-callback
                 #:cut-callback   cut-callback
                 #:copy-callback  copy-callback
                 #:paste-callback paste-callback
                 [parent #f])
  (set! toolbox-plugin-button-callback
        plugin-button-callback)
  (set! toolbox-frame
        (new toolbox-frame% 
             [label application-name];"Toolbox"]
             [min-width 200]
             [parent parent]
             [x 5]
             [y 5]
             [on-close-callback exit-application-callback]
             ))
  
  (let* ([menu (new menu-bar% [parent toolbox-frame])]
         [make-menu (λ (label [help-str #f]) 
                      (new menu% 
                           [parent menu] 
                           [label label] 
                           [help-string help-str]))]
         [menu-file     (make-menu "File")]
         [menu-edit     (make-menu "Edit")]
         [menu-windows  (make-menu "Windows")]
         [menu-help     (make-menu "Help")]
         [current-menu (make-parameter menu-file)]
         [make-menu-item (λ (label shortcut callback)
                           (new menu-item% 
                                [parent (current-menu)]
                                [label label]
                                [shortcut shortcut]
                                [callback (λ _ (callback))]))]
         [make-separator (λ ()
                           (new separator-menu-item%
                                [parent (current-menu)]))]
         )
    (current-menu menu-file)
    (make-menu-item "&New Project"             #\N  new-project-callback)
    (make-menu-item "&Open Project..."         #\O  load-project-callback)
    (make-menu-item "&Save Project"            #\S  save-project-callback)
    (make-menu-item "S&ave Project as..."      'f12 (λ _ (save-project-callback #t)))
    (make-separator)
    (make-menu-item "&Generate Scheme File..." 'f5  generate-code-callback)
    (make-separator)
    (make-menu-item "&Close Project"           #\W  close-project-callback)
    (make-separator)
    (make-menu-item "E&xit"                    #\Q  exit-application-callback)
    
    (current-menu menu-edit)
    ; insert template from a file
    ;(make-menu-item "&Insert Template..."       #f   load-template)
    ; save template to a user-selected file
    ;(make-menu-item "&Save Template as File..." #f   save-template-as)
    ;(make-separator)
    (make-menu-item "C&ut"                     #\X  cut-callback)
    (make-menu-item "&Copy"                    #\C  copy-callback)
    (make-menu-item "&Paste"                   #\V  paste-callback)
    
    (current-menu menu-windows)
    (make-menu-item "Show/Hide &Properties"    #f   show-properties-callback)
    (make-menu-item "Show/Hide &Hierarchy"     #f   show-hierarchy-callback)
    
    (current-menu menu-help)
    (make-menu-item "&Online Help"             'f1  help-online-help)
    (make-menu-item "&PLT MrEd Help"           #f   help-mred-help)
    (make-menu-item "&About MrEd Designer..."  #f   help-about-dialog)
    )

  (set! toolbox-frame-vertical-pane
        (new vertical-pane% 
             [parent toolbox-frame] 
             [alignment '(right top)] 
             [border 3]))

  ; Add the plugin buttons:
  (toolbox-frame-make-plugin-buttons)

  ;; Templates:
  (let* ([gb (new group-box-panel% 
                  [label "Templates"]
                  [parent toolbox-frame-vertical-pane])]
         [hp  (new horizontal-panel% [parent gb]
                   [alignment '(center center)]
                   )]
         [hp2 (new horizontal-panel% [parent gb]
                   [alignment '(center center)]
                   [stretchable-width #t]
                   )]
         [hp3 (new horizontal-panel% [parent gb]
                   [alignment '(center center)]
                   [stretchable-width #t]
                   )]
         )
    ; the list of templates
    (set! lb-templates
          (new choice%
               [parent hp]
               [label #f]
               [min-width 250]
               [stretchable-width #t]
               [choices '()]))
    (toolbox-update-template-choices)
    ; a button to add a template. 
    ; The callback is applied to the file of the selected template.
    (new button%
         [parent hp]
         [label "Insert"]
         [callback (λ _ (add-template-callback (get-selected-template)))]
         )
    (new button%
         [parent hp2]
         [label "Save"]
         [callback (λ _ (save-template-callback 
                         (get-text-from-user "Saving Template ..." 
                                             "Enter a name for the new template:")))]
         )
    (new button%
         [parent hp2]
         [label "Replace"]
         [callback (λ _ (when (eq? 'yes (message-box "Replace?"
                                                     "Are you sure you want to replace the current template?"
                                                     #f '(yes-no)))
                          (replace-template-callback (get-selected-template))))]
         )
    (new button% 
         [parent hp2]
         [label "Delete"]
         [callback (λ _ (when (eq? 'yes (message-box "Delete?"
                                                     "Are you sure you want to delete the current template?"
                                                     #f '(yes-no)))
                          (delete-template-callback (get-selected-template))))]
         )
    ; rename also !
    )

  ; Project:
  (let* ([gbp (new group-box-panel% 
                   [parent toolbox-frame-vertical-pane]
                   [label "Generate code..."])]
         [hp (new horizontal-panel% 
                  [parent gbp]
                  [alignment '(center center)]
                  )]
         )
    (new button%
         [label "To console"]
         [parent hp]
         [min-width 110]
         [callback (λ _ (generate-code-to-console-callback))])
    (new button%
         [label "To <project-id>.rkt"]
         [parent hp]
         [min-width 110]
         [callback (λ _ (generate-code-callback #:ask #f))])
    (new button%
         [label "Save Project"]
         [parent hp]
         [min-width 110]
         [callback (λ _ (save-project-callback))])
    )
    
  ; Enable/disable the toolbar buttons if they can be instantiated with no parent 
  (update-toolbox-frame #f)
  )

(define/provide (show-toolbox-frame)
  (send toolbox-frame show #t))

;; Returns the template file that is selected in the list-box (or choice%)
(define (get-selected-template)
  (let ([sel (send lb-templates get-selection)])
    (and sel (car (list-ref template-dict sel)))))

;; Updates the list of templates
(define/provide (toolbox-update-template-choices)
  (send lb-templates clear)
  ; add the actual templates with the filenames
  (dict-for-each template-dict
                 (λ (k v)
                   (if v 
                     (send lb-templates append v)
                     (printf "Warning: File ~a has a wrong format!\n" k)
                     )
                   ))
  (send lb-templates refresh)
  )

; Holds all the plugin panels
(define plugin-panels (make-hash))

(define (new-plugin-panel label)
  (let ([gbp (new group-box-panel% 
                  (label label) 
                  (parent toolbox-frame-vertical-pane))])
    (new horizontal-pane% 
        (parent gbp))))

;; Returns the button panel to which the plugin belongs.
(define (get-button-panel plugin panel-name)
  (hash-ref! plugin-panels panel-name 
             ; if none found, add a new one
             (λ () (new-plugin-panel panel-name))))

(define (add-plugin-button plugin)
  (let ([button-group (send plugin get-button-group)])
    (when button-group
      (let ([pl-panel (get-button-panel plugin button-group)])
        (new tooltip-button%
             [label (make-object bitmap% 
                      (build-path widget-plugins-path
                                  (send plugin get-dir-name) 
                                  widget-icons-dir "24x24.png")
                      'png 
                      (send the-color-database find-color "white"))]
             [tooltip-text (send plugin get-tooltip)]
             [parent pl-panel]
             [style '(border)]
             [callback (λ (b e) (toolbox-plugin-button-callback plugin))]
             )))))

;; We fill it
(define plugins-buttons '())
(define (toolbox-frame-make-plugin-buttons)
  (set! plugins-buttons
        (map (λ (p) (cons p (add-plugin-button p)))
             (get-widget-plugins))))

;; Enable or disble the toolbar buttons based on whether the represented item can be instantiated
;; for the current parent.
(define/provide (update-toolbox-frame mid)
  (dict-for-each plugins-buttons
                 (λ (p b)
                   (when (send p get-button-group) ; is there a button ?
                     (send b enable (send p can-instantiate? mid))))
                 ))
