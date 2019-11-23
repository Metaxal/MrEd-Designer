#lang racket

;; ##################################################################################
;; # ============================================================================== #
;; # controller.rkt                                                                 #
;; # https://github.com/Metaxal/MrEd-Designer                                       #
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

(require "misc.rkt"
         "preview-widgets.rkt"
         "toolbox-frame.rkt"
         "property-frame.rkt"
         "hierarchy-frame.rkt"
         "code-generation.rkt"
         "templates.rkt"
         framework
         "mred-plugin.rkt" 
         ; for project loading:
         racket/gui/base
         "mred-id.rkt"
         )

; This module makes the binding between the different frames and the model.

(define/provide (controller-exit-application)
  (debug-printf "controller-exit-application:~n")
  (let ([projects (map-send user-data (send hierarchy-widget get-items))])
    (for-each project-changed-save projects))
  (close-window hierarchy-frame)
  (close-window property-frame)
  (close-window toolbox-frame))

(define/provide (controller-show-property-frame)
  (debug-printf "controller-show-property-frame:~n")
  (send property-frame show 
        (not (send property-frame is-shown?))))

(define/provide (controller-show-hierarchy-frame)
  (debug-printf "controller-show-hierarchy-frame:~n")
  (send hierarchy-frame show 
        (not (send hierarchy-frame is-shown?))))

(define/provide (controller-select-mred-id mid)
  (debug-printf "controller-select-mred-id: mid:~a~n" mid)
  (select-mred-id mid)
  (hierarchy-select mid)
  (update-property-frame mid)
  (update-toolbox-frame mid))

(define/provide (controller-replace-current-widget)
  (debug-printf "controller-replace-current-widget: enter~n")
  (send (get-current-mred-id) replace-widget)
  (send hierarchy-widget update-current-mred-id)
  (debug-printf "controller-replace-current-widget: exit~n"))

(define/provide (controller-create-mred-id plugin [mred-parent (get-current-mred-id)])
  (let* ([new-mred-id (send plugin new-mred-id mred-parent)])
    (debug-printf "controller-create-mred-id: ~a ~a ~a~n" (send plugin get-type) mred-parent new-mred-id)
    (when new-mred-id
;      (printf "creating widget from plugin ~a~n" (send plugin get-type))
      (project-changed! new-mred-id)
      ; Call add-children wrapper for add-child - kdh 2012-02-29
      (send hierarchy-widget add-children new-mred-id (or mred-parent 'selected)))

    (debug-printf "controller-replace-current-widget: exit~n")

    ; return:
    new-mred-id))

(define/provide (controller-delete-mred-id [mid (get-current-mred-id)])
  (debug-printf "controller-delete-mred-id: mid:~a~n" mid)
  (when mid
    (let ([mid-parent (send mid get-mred-parent)])
      (unless mid-parent
        (project-changed-save mid))
      (send mid delete)
      (project-changed! mid)
      (send hierarchy-widget delete-mred-id mid)
      (controller-select-mred-id mid-parent))))

(define/provide (controller-move-up)
  (let* ([mid (get-current-mred-id)])
    (debug-printf "controller-move-up:~n")
    (send mid move-up)
    (project-changed!)
    (send hierarchy-widget move-up)))
  
(define/provide (controller-move-down)
  (let* ([mid (get-current-mred-id)])
    (debug-printf "controller-move-down:~n")
    (send mid move-down)
    (project-changed!)
    (send hierarchy-widget move-down)))

; *************
; * Templates *
; *************

;; Loads the mred-id/widget hierarchy from the file
;; and place it under the current mred-id.
;; If any loaded id is already in use in the current hierarchy (project)
;; then it is changed to an unused name.
;; This function is not specific to templates, and is used also for projects
;; and copy/paste (which are in fact templates)
(define (load-mred file parent-mid)
  (when file
    (debug-printf "load-mred: load file ~a~n" file)
    (begin-busy-cursor) ;; TODO: Where is the end?
    (let* ([tlmid (and parent-mid (send parent-mid get-top-mred-parent))]
           [all-ids (if tlmid (map-send get-id (get-all-children tlmid)) '())]
           [all-ids-str (map ->string all-ids)]
           [mids (load-template file parent-mid)])
      (end-busy-cursor)
      (debug-printf "load-mred: load done~n")
      (and mids
           (begin
             (when parent-mid
               ; we must change all the ids that are already in use 
               ; (in the current hierarchy):
               (for-each (λ(m)
                           (let* ([id (send m get-id)]
                                  [id-str (->string id)]
                                  ; Must use string because some symbols may be interned and some not!
                                  ; (because of gensym...)
                                  [id-exists? (member id-str all-ids-str)])
                             (when id-exists?
                               (send m set-random-id))))
                         mids)
               )
             ; create a hierarchy with these mred-ids:
             ; Call add-children wrapper for add-child - kdh 2012-02-29      
             (send hierarchy-widget add-children (first mids) (or parent-mid 'none))

             (debug-printf "load-mred: exit~n")

             ; return value:
             mids)))))
         
(define/provide (controller-load-template file [parent-mid (get-current-mred-id)])
  (debug-printf "controller-load-template: ~a ~a~n" file parent-mid)
  (when file
    (unless (load-mred file parent-mid)
      (printf "Error: cannot load template file ~a~n" file))))

(define/provide (controller-save-template name [file #f] [mid (get-current-mred-id)])
  (debug-printf "controller-save-template: \"~a\" \"~a\" ~a~n" name file mid)
  (when mid
    (save-template mid name file)
    (controller-update-templates)
    )
  (debug-printf "controller-save-template: exit~n")
  ; specify return value - kdh 2012-07-09      
  (void))

(define/provide (controller-replace-current-template file)
  (debug-printf "controller-replace-current-template: file:~a~n" file)
  (save-template (get-current-mred-id) (get-template-name file) file)
  ;(controller-update-templates)
  (debug-printf "controller-replace-current-template: exit~n")
  ; specify return value - kdh 2012-07-09      
  (void))
  
(define/provide (controller-delete-template file)
  (debug-printf "controller-delete-template:~n")
  (delete-template file)
  (controller-update-templates))

(define/provide (controller-update-templates)
  (make-template-dict)
  (toolbox-update-template-choices))

;; Copy/Cut/Paste a mred-id and its children
(define/provide (controller-copy)
  (controller-save-template "Clipboard" (template-file "clipboard")))

(define/provide (controller-cut)
  (controller-copy)
  (controller-delete-mred-id)
  (project-changed!))

(define/provide (controller-paste)
  (controller-load-template (template-file "clipboard"))
  (project-changed!))

(define/provide (controller-show/hide)
  (send (get-current-mred-id) show/hide))

; ********************
; * Saving & Loading *
; ********************

; These functions are specific to the `project%' plugin,
; so it should probably not be here !

; BAD!
; Depends on the property structure!!
(define (set-project-changed project-mid val)
  (send 
   (send (send project-mid get-property 'changed) get-prop) 
   set-value val))  

;; Sets the 'changed' status of the top-level-mred-id (a project mred-id) to #t
(define/provide (project-changed! [some-mid-child (get-current-mred-id)])
  (set-project-changed (send some-mid-child get-top-mred-parent) #t))

(define/provide (controller-close-project [some-mild-child (get-current-mred-id)])
  (debug-printf "controller-close-project:~n")
  (when some-mild-child
    (let ([mid (send some-mild-child get-top-mred-parent)])
      (controller-delete-mred-id mid))))

;; Asks for saving the project if it has changed since last save/load
(define/provide (project-changed-save project-mid)
  (when (send project-mid get-property-value 'changed)
    (let ([save? (message-box 
                  "Save project?" 
                  (string-append*
                   "Do you want to save the project " 
                   (send project-mid get-id)
                   " before closing it?")
                  #f
                  '(yes-no caution))])
      (when (equal? save? 'yes)
        (controller-save-project #f project-mid)))))

(define/provide (controller-new-project)
  (let ([project-mid 
         (controller-create-mred-id (get-widget-plugin 'project) #f)])
    (set-project-changed project-mid #f) ; empty project are not "changed" (don't ask for saving it)
    (controller-select-mred-id project-mid)))

;; Loads the mred-id/widget hierarchy from the file
;; and place it at the top (no parent)
;; Simplified to return #t on success, #f otherwise - kdh 2012-02-29
(define/provide (load-project file)
  (debug-printf "load-project: ~a~n" file)
  (set! file (path->complete-path file (find-system-path 'orig-dir)))
  (debug-printf "complete path: ~a\n" file)
  ;(debug-printf "current-dir: ~a\n"(current-directory))
  (parameterize ([current-directory (path-only file)])
    (let ([mids (load-mred file #f)])
      (or
       (and mids
            (let ([proj-mid (first mids)])
              (send (send (send proj-mid get-property 'file) get-prop)
                    set-value (path->string file))
              (set-project-changed proj-mid #f)
              (controller-select-mred-id proj-mid)
              #;(debug-printf "load-project: exit~n")
              ; Simplify return value - kdh 2012-02-29
              ; return value:
              #t))
       (and (printf "Error: cannot load project ~a~n" file)
            ; return value:
            #f)))))

; The controller has been compromised!
; There are GUI elements in the controller!
; Yurk! ... (Yes, I should clean that. Yes.)

;; Simplified to return #t on success, #f otherwise - kdh 2012-02-29
(define/provide (controller-load-project)
  (let ([file (get-file "Select a MrEd Designer Project File"
                        #f #f #f "med" '()
                        '(("MrEd Designer Project File" "*.med"))
                        )])
    ; Simplify return value - kdh 2012-02-29
    (and file
         (load-project file))))

(define/provide (save-project mid file)
  (debug-printf "save-project: enter~n")
  (when mid
    (debug-printf "Saving project in ~a\n" file)
    (begin-busy-cursor)
    (let ([project-mid (send mid get-top-mred-parent)])
      (send (send (send project-mid get-property 'file) get-prop)
            set-value (path-string->string file))
      (save-template project-mid (->string (send project-mid get-id)) file)
      ;(save-mred-id project-mid file)
      (set-project-changed project-mid #f)
      )
    (end-busy-cursor)
    (debug-printf "save-project: exit~n"))
  ; specify return value - kdh 2012-07-09      
  (void))

(define/provide (controller-save-project [save-as? #f] [mid (get-current-mred-id)])
  (debug-printf "controller-save-project: save-as?:~a mid:~a ~n" save-as? mid)
  (when mid
    (let* ([project-mid (send mid get-top-mred-parent)]
           [file (or (and (not save-as?)
                          (send project-mid get-property-value 'file))
                     ; or ask for file:
                     (put-file "Select a file to save your MrEd Designer Project"
                               toolbox-frame
                               #f
                               (symbol->string (send project-mid get-id))
                               "*.med"
                               '()
                               '(("MrEd Designer Project (.med)"  "*.med"))
                               ))]
           [file (and file (path-replace-suffix file ".med"))])
      (when file
        (save-project project-mid file))))

  (debug-printf "controller-save-project: done~n")
  ; specify return value - kdh 2012-07-09      
  (void))

(define (choose-code-file dft-name [base-path #f] [parent-frame #f])
  (let ([base-path (and base-path (normal-case-path (simple-form-path base-path)))]
        [file (put-file  "Select the file to generate the code to"
                         parent-frame
                         base-path
                         dft-name  
                         "*.rkt"
                         '()
                         '(("Racket (.rkt)"  "*.rkt")
                           ("Any"           "*.*")))])
    (and file
         (path->string file))))

;; Like frame:text% but without exiting the app when closing the window
(define no-exit-frame:text%
  (class frame:text%
    (super-new)
    (define/override (on-exit)
      ;(printf "on-exit\n")
      (void))
    (define/override (can-exit?)
      ;(printf "can-exit?\n")
      #f)
    (define/augment (on-close)
      ;(printf "on-close\n")
      (void))
    (define/augment (can-close?)
      ;(printf "can-close?\n")
      (send this show #f)
      #f)
    ))

(define/provide (controller-generate-code-to-frame [mid (get-current-mred-id)])
  (when mid
    (define project-mid (send mid get-top-mred-parent))
    (define f (new no-exit-frame:text%  
                   [min-height 500]))
    (send f set-label (->string (send project-mid get-id)))
    (define txt (send f get-editor))
    (send txt insert
          (with-output-to-string (λ _ (generate-module project-mid))))
    (send f show #t))) 

(define/provide (controller-generate-code [mid (get-current-mred-id)]
                                          #:ask [ask-user? #t])
  (when mid
    (let* ([project-mid (send mid get-top-mred-parent)]
           [base-dir (send project-mid get-project-dir)]
           [dft-file (string-append (->string (send project-mid get-id)) ".rkt")]
           [file (if (or ask-user? (not base-dir))
                     (choose-code-file dft-file base-dir toolbox-frame)
                     (path->complete-path dft-file base-dir))]
           )
      (when file
        (debug-printf "Generating code in file ~a\n" file)
        (with-output-to-file file
          (λ()(generate-module project-mid))
          #:exists 'replace)))))
