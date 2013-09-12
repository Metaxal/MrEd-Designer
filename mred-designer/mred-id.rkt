#lang racket/gui

(require "code-write.rkt"
         "properties.rkt"
         "misc.rkt"
         )

(define/provide current-generate-code (make-parameter #f))

(define/provide mred-widget<%> (interface () ))

(define/provide (mred-widget%% c%)
  (class* c% (mred-widget<%>)
    (init-field mred-id)
    (getter mred-id)

    ; at the bottom, because f the dialog% widget that is blocking...
    (super-new)
    ))

;; The object holding a preview-widget (widgets that area created by the user).
;; If the widget values change, it must be recreated from scratch,
;; but the holder does not have to change (only its properties).
;; This makes things simpler.
(define/provide mred-id%
  (class (code-write%% object%)
    (super-new)
    (init-field plugin
                mred-parent 
                properties
                [widget #f]
                )
    (field [mred-children '()]
           )
    
    (getter/setter widget properties plugin mred-parent)

    ; Tell our parent that we are its child
    (when mred-parent 
      (send mred-parent add-mred-child this))
    
    ; Verify that we have all the properties
    ; otherwise add them:
    (let ([props-def (send plugin make-properties)])
      (set! properties
            (map (λ(dp)(let ([p (findf (λ(p)(equal? (car dp) (car p)))
                                       properties)])
                         (or p dp)))
                 props-def)))
    
    ;; Returns the mred-id% ancestor that has no mred-id parent.
    ;; (it may have a non-mred-id parent?)
    (define/public (get-top-level-mred-id)
      (if (is-a? mred-parent mred-id%)
          (send mred-parent get-top-level-mred-id)
          this))
    
    ;; Because of the plugin, we must redefine how arguments are printed
    (define/override (code-write-args)
      ;(printf "code-write-args: ~a\n" (get-id))
      ; now return the values needed 
      (list (list 'plugin (list 'get-widget-plugin 
                                (list 'quote (send plugin get-type)))) 
            ; get-widget-plugin must then be reachable...
            (list 'mred-parent (code-write-value mred-parent))
            ; must handle hierarchical dependencies!
            (list 'properties (code-write-value properties))
            )
      )
    
    ;; Returns the property<%> corresponding to the given field-id
    (define/public (get-property field-id)
      (dict-ref properties field-id))
    
    ;; Returns the value of a given property
    (define/public (get-property-value field-id)
      (send (get-property field-id) get-value))
    
    (define/public (get-id) (get-property-value 'id))

    ;(define/public (get-code-gen-class-symbol) (get-property-value 'code-gen-class))
    
    ;; Changes the id to put a random one based on the type of the plugin
    (define/public (set-random-id)
      (send (send (get-property 'id) get-prop) 
            set-value (send plugin get-random-id)))
    
    (define/public (is-type? t)
      (equal? t (get-property-value 'type)))
    
    (define/public (get-mred-children) (reverse mred-children))

    (define/public (add-mred-child w)
      (set! mred-children (cons w mred-children)))
    
    ;; WARNING!
    ;; Can only change simple props, not compound ones!
    (define/public (change-property-value field-id new-flat-val)
      (send (send (dict-ref properties field-id) get-prop)
            set-value new-flat-val))
    
    (define (create-widget parent [props properties])
      (set! widget (send plugin make-widget this parent props))
      (set! properties props)
      )
    
    (define (get-parent-widget)
      (and mred-parent
           (send mred-parent get-widget)))
    
    (define/public (can-change-child? child)
      (and (object-method-arity-includes? widget 'change-children 1)
           (member child (send widget get-children))
           ))
      
    ;; When the properties have changed,
    ;; The widget must be recreated from scratch
    (define/public (replace-widget)
      (recreate-top-level-window)
      ; The following could still be used:
;      (if (and mred-parent (send mred-parent can-change-child? this))
;          (let* ([old-widget widget]
;                 [parent (get-parent-widget)]
;                 [new-widget (recreate-widget-hierarchy parent)]
;                 )
;            (when parent 
;              (send parent change-children
;                    (λ(l)
;                      (append-map (λ(x)(cond [(eq? x old-widget) (list new-widget)] ; replace
;                                             [(eq? x new-widget) '()] ; delete the new if present
;                                             [else (list x)]
;                                             ))
;                                  l))))
;            (when (is-a? old-widget top-level-window<%>)
;              (close-window old-widget))
;            ; recreer tous les enfants
;            ; en changeant le widget père
;            )
;          ; else, cannot change children, redraw the whole top-level-window:
;          (recreate-top-level-window)
;          )
      )
    
    (define/public (recreate-widget-hierarchy [parent (get-parent-widget)])
      (let ([shown (and (is-a? widget top-level-window<%>) (send widget is-shown?))])
        (debug-printf "recreate-widget-hierarchy: enter\n")

        ; if widget is a frame% or dialog%, close it first:
        (when shown
          (close-window widget))
        
        ; replace the widget by a new one:
        (set! widget (send plugin make-widget this parent properties))
        
        ; recreate all the children in order:
        (when (is-a? widget area-container<%>)
          (send widget begin-container-sequence))
        
        (for-each-send (recreate-widget-hierarchy widget) (get-mred-children))

        ; end-container-sequence before showing the window - kdh 2012-04-17
        (when (is-a? widget area-container<%>)
          (send widget end-container-sequence))
        
        (when (is-a? widget top-level-window<%>)
          (send widget show shown)) ; show it or hide it

        (debug-printf "recreate-widget-hierarchy: exit\n")

        ; return value:
        widget))
      
    (define/public (delete)
      (debug-printf "delete: enter\n")

      ; close window before deleting its children - kdh 2012-04-17
      (when (is-a? this top-level-window<%>)
        (close-window this))

      ; hide window before deleting its children - kdh 2012-04-17
      (show #f)

      ; begin-container-sequence before deleting its children - kdh 2012-04-17
      (when (is-a? this area-container<%>)
        (send this begin-container-sequence))

      (for-each-send delete (get-mred-children))
      
      ; end-container-sequence after deleting its children - kdh 2012-04-17
      (when (is-a? this area-container<%>)
        (send this end-container-sequence))

      (when mred-parent ;(and mred-parent (member this (send mred-parent get-children)))
        (send mred-parent delete-child this))

      (debug-printf "delete: exit\n")

      ; return void always - kdh 2012-04-17
      (void)
      )
    
    (define/public (show s)
      (when (and widget (object-method-arity-includes? widget 'show 1))
        (send widget show s)))
    
    (define/public (show/hide)
      (when (and widget (object-method-arity-includes? widget 'show 1))
        (send widget show (not (send widget is-shown?)))))
    
    ; Returns the topmost mred-id of the current hierarchy (a project%)
    (define/public (get-top-mred-parent)
      (if mred-parent
          (send mred-parent get-top-mred-parent)
          this))
    
    (define/public (get-project-dir)
      (let* ([top-mid (get-top-mred-parent)] ; the project-mid
             [proj-file (send top-mid get-property-value 'file)])
        (and proj-file (path-only (string->path proj-file)))))
    
    ; returns the topmost WINDOW of the current hierarchy (a frame%, not a project%)
    (define/public (get-top-level-window-mred-id)
      (if (is-a? widget top-level-window<%>)
          this
          (and mred-parent
              (send mred-parent get-top-level-window-mred-id))
          ))
    
    ;; Needed when just replacing the current widget does not work:
    (define/public (recreate-top-level-window)
      (let* ([tlw-mid (get-top-level-window-mred-id)]
             [base-dir (get-project-dir)]
             )
        (when tlw-mid
          ;(close-window (send tlw-mid get-widget))
          (parameterize ([current-directory (or base-dir (current-directory))])
            (send tlw-mid recreate-widget-hierarchy))
          ;(send tlw-mid show #t)
          )))
    
    (define/public (delete-child mid)
      (set! mred-children (remq mid mred-children))
      (let ([midw (send mid get-widget)])
        (if (is-a? midw subwindow<%>)
            (when (member midw (send widget get-children))
              (send widget delete-child midw))
            (recreate-top-level-window))
        ))
    
    (define/public (move-up)
      (and mred-parent (send mred-parent move-up-child this)))

    (define/public (move-up-child mid-child)
      ; move-right because the list is reverse order
      (set! mred-children (list-move-right mred-children mid-child)) 
      (if (can-change-child? mid-child)
          (send widget change-children
                (λ(l)(list-move-left l (send mid-child get-widget))))
          (recreate-top-level-window)
        ))
           
    (define/public (move-down)
      (and mred-parent (send mred-parent move-down-child this)))
    
    (define/public (move-down-child mid-child)
      ; move-left because the list is reverse order
      (set! mred-children (list-move-left mred-children mid-child)) 
      (if (can-change-child? mid-child)
          (send widget change-children
                (λ(l)(list-move-right l (send mid-child get-widget))))
          (recreate-top-level-window)
          ))
    
    ;;; Code generation
    
    ;; Code specific to the plugin,
    ;; added before the init function.
    ;; Must return a list of symbols.
    ;; Also ask to each property if it wants to generate something (e.g., a definition)
    (define/public (generate-pre-code)
      (parameterize ([current-property-mred-id this])
        (append (send plugin generate-pre-code this)
                (append-map (λ(p)(if (send (cdr p) get-no-code)
                                     '()
                                     (send (cdr p) generate-pre-code)))
                            properties))))
           
    ;; Generate the options in the init-function
    (define/public (generate-options)
      (parameterize ([current-property-mred-id this])
        (append-map (λ(p)(if (send (cdr p) get-no-code)
                             '()
                             (send (cdr p) generate-option (string-append* (get-id) "-"))))
                    properties)))
    
    ;; Generate the setter in the init-function
    ;; (the define is made automatically)
    (define/public (generate-code)
      (parameterize ([current-generate-code #t]
                     [current-property-mred-id this])
        (let* ([parent-id (if mred-parent (send mred-parent get-id) #f)]
               [id (get-id)]
               [prefix (string-append* id "-")])
          `(set! ,id
                 ;(new ,(send plugin get-code-gen-class-symbol)
                 (new ,(send (get-property 'code-gen-class)
                             generate-code prefix)
                      (parent ,parent-id)
                      ,@(append-map
                         (λ(p)(if (or (send (cdr p) get-no-code)
                                      (equal? (car p) 'code-gen-class))
                                  '()
                                  (list (list (car p) 
                                              (send (cdr p) generate-code prefix)))))
                         properties)
                      ))
          )))
    
    ;; Code specific to the plugin,
    ;; added after all the setters.
    ;; Must return a list of symbols.
    (define/public (generate-post-code)
      (send plugin generate-post-code this))

    ;; Finally, generate the widget:
    (create-widget (get-parent-widget))
    
    ))

;; Returns the list with w + all the children of w if w is a container.
(define/provide (get-all-children mid)
  (cons mid
        (append-map get-all-children
                    (send mid get-mred-children))
    )
  )


