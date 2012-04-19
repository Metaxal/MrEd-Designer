;; ##################################################################################
;; # ============================================================================== #
;; # Graph Editor                                                                   #
;; # http://www.hexahedron.hu/private/peteri/                                       #
;; # Copyright (C) Peter Ivanyi, 2007                                               #
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

(module graph-editor mzscheme
  
  (require (lib "class.ss")  
           (lib "mred.ss" "mred")
           (lib "list.ss")
  )
  
  
  (define tab-width 10)
  (define tab-height 10)
  (define node-width 60)
  (define node-height 25)
  (define node-buffer 5)
  (define node-color  (make-object color% 91 91 184))
  (define white-color (make-object color% "white"))
  
  (provide line%)
  (define line%
    (class object%
      (init-field
        (source #f) ; stores the source tab object
        (target #f) ; stores the destination tab object
        (editor #f)
      )
      
      ; user defined data structure
      ; if the user wants to store anything in the node
      (define data #f)
      
      (public get-data)
      (define (get-data)
        data
      )
      
      (public set-data)
      (define (set-data dat)
        (set! data dat)
      )

      (define visible? #f)
      
      (public is-shown?)
      (define (is-shown?)
        visible?
      )
      
      (public get-source)
      (define (get-source)
        source
      )
      
      (public get-target)
      (define (get-target)
        target
      )
      
      (define (draw show?)
        (set! visible? show?)
        (let
          ((dc (send editor get-dc))
           (src-type (send source get-type))
           (dst-type (send target get-type))
          )
          (if show?
            (send dc set-pen "black" 1 'solid)
            (send dc set-pen "white" 1 'solid)
          )
          (let-values
            (((sx sy) (send source get-position))
             ((tx ty) (send target get-position))
            )
            (cond
              ((equal? src-type 'out) (set! sy (+ sy tab-height -1)))
              ((equal? src-type 'in)  (set! sy (- sy tab-height))))
            (cond
              ((equal? dst-type 'out) (set! ty (+ ty tab-height -1)))
              ((equal? dst-type 'in)  (set! ty (- ty tab-height))))
            (send dc draw-line sx sy tx ty)
          )
        )
      )
      
      (public show)
      (define (show)
        (draw #t)
      )
      
      (public hide)
      (define (hide)
        (draw #f)
      )
      
      (super-new)
    )
  )
  
  ; ----------------------------------------------------------------------------
  ; tab
  ; ----------------------------------------------------------------------------
  (provide tab%)
  (define tab%
    (class object%
      (init-field
        (x 0) (y 0)
        (type #f) ; can be in or out
        (node #f)
        (editor #f)
      )
      
      (define visible? #f)
      
      ; all lines connected to this tab
      (define lines '())
      
      (public line-add)
      (define (line-add line)
        (set! lines (cons line lines))
      )
      
      (public line-del)
      (define (line-del line)
        (set! lines (remove line lines))
      )
      
      (public get-lines)
      (define (get-lines)
        (if (and (equal? type 'in)
                 (> (length lines) 1))
          (error "too many lines connected to an in tab")
        )
        lines
      )
      
      (public connected?)
      (define (connected?)
        (if (> (length lines) 0)
          #t #f
        )
      )
      
      (public is-shown?)
      (define (is-shown?)
        visible?
      )
      
      (public get-type)
      (define (get-type)
        type
      )
      
      (public get-node)
      (define (get-node)
        node
      )
      
      (public x-set!)
      (define (x-set! cx)
        (set! x cx)
      )
      
      (public y-set!)
      (define (y-set! cy)
        (set! y cy)
      )
      
      (public get-position)
      (define (get-position)
        (values x y)
      )
      
      (public get-line-position)
      (define (get-line-position)
        (if (equal? type 'in)
          (values x (- y tab-height))
          (values x (+ y tab-height -1))
        )
      )
      
      (define (draw show?)
        (set! visible? show?)
        (let
          ((dc (send editor get-dc)))
          (if show?
            (send dc set-pen "black" 1 'solid)
            (send dc set-pen "white" 1 'solid)
          )
          (send dc set-brush node-color 'solid)
          (cond
            ((equal? type 'in)
             (send dc draw-rectangle 
                   (- x (* tab-width 0.5)) (+ (- y tab-height) 0)
                   tab-width tab-height)
             (send dc set-pen "white" 1 'solid)
             (send dc draw-line
                   (- x (* tab-width 0.5)) 
                   (+ (- y tab-height) 0)
                   (- x (* tab-width 0.5))
                   (+ (- y tab-height) tab-height))
             (send dc draw-line
                   (- x (* tab-width 0.5))
                   (+ (- y tab-height) 0)
                   (+ (- x (* tab-width 0.5)) tab-width)
                   (+ (- y tab-height) 0))
            )
            ((equal? type 'out)
             (send dc draw-rectangle 
                   (- x (* tab-width 0.5)) (- y 0)
                   tab-width tab-height)
             (send dc set-pen "white" 1 'solid)
             (send dc draw-line
                   (- x (* tab-width 0.5)) (- y 0)
                   (- x (* tab-width 0.5)) (+ y tab-height))
             (send dc draw-line
                   (- x (* tab-width 0.5)) (- y 0)
                   (+ (- x (* tab-width 0.5)) tab-width) (- y 0))
            )
          )
          (for-each
            (lambda (lin)
              (if show?
                (send lin show)
                (send lin hide)
              )
            )
            lines
          )
        )
      )
      
      (public show)
      (define (show)
        (draw #t)
      )
      
      (public hide)
      (define (hide)
        (draw #f)
      )
      
      (public on-mouse)
      (define (on-mouse etype cx cy)
        (cond
          ((member etype '(left-down left-up))
           (cond
             ((and (equal? type 'in)
                   (<= (- x (* tab-width  0.5)) cx (+ x (* tab-width  0.5)))
                   (<= (- y tab-height) cy y))
              this
             )
             ((and (equal? type 'out)
                   (<= (- x (* tab-width  0.5)) cx (+ x (* tab-width  0.5)))
                   (<= y cy (+ y tab-height)))
              this
             )
             (else #f)
            )
          )
          (else #f)
        )
      )
      
      (super-new)
    )
  )
  
  
  ; ----------------------------------------------------------------------------
  ; node
  ; ----------------------------------------------------------------------------
  
  (provide node%)
  (define node%
    (class object%
      (init-field
        (id #f) ;id of the node in the graph editor
        (name #f) ; name to display
        (x 0) ; center x coordinate of the rectangle
        (y 0) ; center y coordinate of the rectangle
        (editor #f)
        (style '())
      )
            
      (define tab-in (make-hash-table 'equal))
      (define tab-out (make-hash-table 'equal))
      (define width 0)
      (define height 0)
      (define offset 5)
      (define visible? #f)
      
      ; user defined data structure
      ; if the user wants to store anything in the node
      (define data #f)
      
      (public get-data)
      (define (get-data)
        data
      )
      
      (public set-data)
      (define (set-data dat)
        (set! data dat)
      )
      
      (public get-id)
      (define (get-id)
        id
      )
      
      (public get-name)
      (define (get-name)
        name
      )
      
      (public set-name)
      (define (set-name str)
        (hide #f)
        (set! name str)
        (set! width (get-real-width))
        (show #f)
        (send editor layout id)
      )
      
      (public get-x)
      (define (get-x)
        x
      )
      
      (public get-y)
      (define (get-y)
        y
      )
      
      (public get-style)
      (define (get-style)
        style
      )

      (public is-shown?)
      (define (is-shown?)
        visible?
      )
      
      (define (get-real-width)
        (let
          ((dc (send editor get-dc)))
          (let-values
            (((tw th td ta) (send dc 
                                  get-text-extent
                                  name
                                  #f
                                  #f 0)))
            (max 70 (+ (* offset 2) tw))
          )
        )
      )
      
      (define (get-real-height)
        (let
          ((dc (send editor get-dc)))
          (let-values
            (((tw th td ta) (send dc 
                                  get-text-extent
                                  name
                                  #f
                                  #f 0)))
            (max 30 (+ (* offset 2) ta td th))
          )
        )
      )
      
      (public x-set!)
      (define (x-set! cx)
        (set! x cx)
        (let*
          ((n (- (hash-table-count tab-in) 1))
           (req-width (* (+ n n 3) tab-width))
           (left (* (- width req-width) 0.5))
           (sx (+ (- x (* width 0.5)) left (* 1.5 tab-width)))
          )
          (do ((i 0 (+ i 1))) ((= i (hash-table-count tab-in)))
            (let
              ((tab (hash-table-get tab-in i)))
              (send tab x-set! sx)
              (set! sx (+ sx (* 2 tab-width)))
            )
          )
        )
        (let*
          ((n (- (hash-table-count tab-out) 1))
           (req-width (* (+ n n 3) tab-width))
           (left (* (- width req-width) 0.5))
           (sx (+ (- x (* width 0.5)) left (* 1.5 tab-width)))
          )
          (do ((i 0 (+ i 1))) ((= i (hash-table-count tab-out)))
            (let
              ((tab (hash-table-get tab-out i)))
              (send tab x-set! sx)
              (set! sx (+ sx (* 2 tab-width)))
            )
          )
        )
      )
      
      (public y-set!)
      (define (y-set! cy)
        (set! y cy)
        (do ((i 0 (+ i 1))) ((= i (hash-table-count tab-in)))
          (let
            ((tab (hash-table-get tab-in i)))
            (send tab y-set! (- y (/ height 2.0)))
          )
        )
        (do ((i 0 (+ i 1))) ((= i (hash-table-count tab-out)))
          (let
            ((tab (hash-table-get tab-out i)))
            (send tab y-set! (+ y (/ height 2.0)))
          )
        )
      )
      
      (public get-position)
      (define (get-position)
        (values x y)
      )
      
      (public get-size)
      (define (get-size)
        (values width height)
      )
      
      (public tab-in-count)
      (define (tab-in-count)
        (hash-table-count tab-in)
      )
      
      (public tab-out-count)
      (define (tab-out-count)
        (hash-table-count tab-out)
      )
      
      (public tab-in-ref)
      (define (tab-in-ref i)
        (if (>= i 0)
          (hash-table-get tab-in i #f)
        )
      )
      
      (public tab-out-ref)
      (define (tab-out-ref i)
        (if (>= i 0)
          (hash-table-get tab-out i #f)
        )
      )
      
      (public tab-in-connected?)
      (define (tab-in-connected?)
        (tab-connected? tab-in)
      )
      
      (public tab-out-connected?)
      (define (tab-out-connected?)
        (tab-connected? tab-out)
      )
      ; check whether any of the tabs is connected
      (define (tab-connected? tab-list)
        (let
          ((connected? #f)
           (n (hash-table-count tab-list))
          )
          (do ((i 0 (+ i 1))) ((or connected? (= i n)))
            (set! connected? (or connected? 
                                 (send (hash-table-get tab-list i #f) connected?)))
          )
          connected?
        )
      )
      
      (public tab-in-decr)
      (define (tab-in-decr)
        (tab-decr tab-in 'in)
      )
      (public tab-out-decr)
      (define (tab-out-decr)
        (tab-decr tab-out 'out)
      )
      
      (define (tab-decr tab-list type)
        (let*
          ((n (hash-table-count tab-list)))
          (if (> n 0)
            (let
              ((last (hash-table-get tab-list (- n 1))))
              (if (not (send last connected?))
                (let
                  ((n (- n 1))
                   (ni (hash-table-count tab-in))
                   (no (hash-table-count tab-out))
                   (max-width #f)
                   (req-width (* (+ n n 0) tab-width))
                  )
                  (hide #f)
                  (hash-table-remove! tab-list n)
                  (if (equal? type 'in)
                    (set! max-width (max (* (- (+ ni ni) 1) tab-width)
                                         (* (+ (+ no no) 1) tab-width)))
                    (set! max-width (max (* (+ (+ ni ni) 1) tab-width)
                                         (* (- (+ no no) 1) tab-width)))
                  )
                  (set! width (max (get-real-width) max-width))
                  (let*
                    ((left (* (- width req-width) 0.5))
                     (sx (+ (- x (* width 0.5)) left (* 2 tab-width)))
                    )
                    (do ((i 0 (+ i 1))) ((= i n))
                      (let
                        ((tab (hash-table-get tab-list i)))
                        (send tab x-set! sx)
                        (set! sx (+ sx (* 2 tab-width)))
                      )
                    )
                  )
                  (show #f)
                  (send editor on-paint)
                )
              )
            )
          )
        )
      )
      
      (public tab-in-incr)
      (define (tab-in-incr)
        (tab-incr tab-in 'in)
      )
      (public tab-out-incr)
      (define (tab-out-incr)
        (tab-incr tab-out 'out)
      )
      
      (define (tab-incr tab-list type)
        (hide #f)
        (let*
          ((n (hash-table-count tab-list))
           (ni (hash-table-count tab-in))
           (no (hash-table-count tab-out))
           (max-width #f)
           (req-width (* (+ n n 3) tab-width))
          )
          (if (equal? type 'in)
            (set! max-width (max (* (+ ni ni 3) tab-width)
                                 (* (+ no no 1) tab-width)))
            (set! max-width (max (* (+ ni ni 1) tab-width)
                                 (* (+ no no 3) tab-width)))
          )
          (set! width (max (get-real-width) max-width))
          (let*
            ((left (* (- width req-width) 0.5))
             (sx (+ (- x (* width 0.5)) left (* 1.5 tab-width)))
            )
            (do ((i 0 (+ i 1))) ((= i n))
              (let
                ((tab (hash-table-get tab-list i)))
                (send tab x-set! sx)
                (set! sx (+ sx (* 2 tab-width)))
              )
            )
            (let
              ((tab (make-object tab% 
                                 sx 
                                 (if (equal? type 'in)
                                   (- y (/ height 2.0))
                                   (+ y (/ height 2.0))
                                 )
                                 type this editor)))
              (hash-table-put! tab-list n tab)
            )
          )
          (show #f)
          (send editor layout id)
        )
      )
      
      (define (draw show? selected?)
        (set! visible? show?)
        (let
          ((dc (send editor get-dc))
           (color #f)
          )
          ; draw or undraw selected square
          (if (and show? selected?)
            (set! color (make-object color% 240 240 240))
            (set! color (get-panel-background))
          )
          (send dc set-pen color 1 'solid)
          (send dc set-brush color 'solid)
          (send dc draw-rectangle 
                (- x (/ width 2.0))
                (- y (/ height 2.0) tab-height)
                width
                (+ height tab-height tab-height))
          ; draw the node square
          (if show?
            (send dc set-pen "black" 1 'solid)
            (send dc set-pen "white" 1 'solid)
          )
          (send dc set-brush node-color 'solid)
          ; draw boundary border
          (send dc draw-rectangle 
                (- x (/ width 2.0))
                (- y (/ height 2.0))
                width
                height)
          ; draw a white line on top and left
          (send dc set-pen "white" 1 'solid)
          (send dc draw-line 
                (- x (/ width 2.0))
                (- y (/ height 2.0))
                (- x (/ width 2.0))
                (+ (- y (/ height 2.0)) height))
          (send dc draw-line 
                (- x (/ width 2.0))
                (- y (/ height 2.0))
                (+ (- x (/ width 2.0)) width)
                (- y (/ height 2.0)))
          ; draw the text
          (if show?
            (let-values
              (((tw th td ta) (send dc 
                                    get-text-extent
                                    name
                                    #f
                                    #f 0)))
              (send dc set-text-foreground white-color)
              (send dc draw-text name 
                    (- x (* tw 0.5)) (- y (* (+ th ta) 0.5))
                    #f 0 0)
            )
          )
        )
        
        (do ((i 0 (+ i 1))) ((= i (hash-table-count tab-in)))
          (let
            ((tab (hash-table-get tab-in i)))
            (if show?
              (send tab show)
              (send tab hide)
            )
          )
        )
        
        (do ((i 0 (+ i 1))) ((= i (hash-table-count tab-out)))
          (let
            ((tab (hash-table-get tab-out i)))
            (if show?
              (send tab show)
              (send tab hide)
            )
          )
        )
        
      )
      
      (public show)
      (define (show selected?)
        (draw #t selected?)
      )
      
      (public hide)
      (define (hide selected?)
        (draw #f selected?)
      )
      
      (public on-mouse)
      (define (on-mouse type cx cy)
        (cond
          ((member type '(left-down left-up))
           (cond
             ((and (<= (- x (* width  0.5)) cx (+ x (* width  0.5)))
                   (<= (- y (* height 0.5)) cy (+ y (* height 0.5))))
              this
             )
             (else
              (let 
                ((found? #f)
                 (n-in  (hash-table-count tab-in))
                 (n-out (hash-table-count tab-out))
                )
                (do ((i 0 (+ i 1))) ((or found? (= i n-in)))
                  (set! found? (send (hash-table-get tab-in i #f) on-mouse type cx cy))
                )
                (do ((i 0 (+ i 1))) ((or found? (= i n-out)))
                  (set! found? (send (hash-table-get tab-out i #f) on-mouse type cx cy))
                )
                found?
              )
             )
            )
          )
          (else #f)
        )
      )
      
      (super-new)
      
      ; determine the size
      (set! width  (get-real-width))
      (set! height (get-real-height))
      
      ; create input tabs
      (if (not (member 'no-input style))
        (hash-table-put! tab-in
                         (hash-table-count tab-in)
                         (make-object tab% 
                                      x (- y (/ height 2.0))
                                      'in  this editor)))
      ; create output tabs
      (if (not (member 'no-output style))
        (hash-table-put! tab-out
                         (hash-table-count tab-out)
                         (make-object tab% 
                                      x (+ y (/ height 2.0))
                                      'out this editor)))
    )
  )
  
  ; ----------------------------------------------------------------------------
  ; graph editor
  ; ----------------------------------------------------------------------------
  
  (provide graph-editor%)
  (define graph-editor%
    (class canvas%
      (init-field
        (callback #f)
        (font #f)
      )
      (unless (or (not callback) 
                  (procedure-arity-includes? callback 2))
        (raise-type-error 'graph-editor%
                          "procedure of arity 2"
                          callback)
      )
      (unless (or (not font) 
                  (is-a? font font%))
        (raise-type-error 'graph-editor%
                          "fond%"
                          font)
      )
      (if (not font)
        (set! font normal-control-font)
      )
      
      ; these variables are used for smooth scrolling
      ; we use this bitmap instead of the default bitmap
      (define bitmap #f)
      (define b-dc #f)
      (define bitmap-width 0)
      (define bitmap-height 0)
      (define x-offset 0)
      (define y-offset 0)
      (define vertical-scroll-step 20)
      (define horizontal-scroll-step 20)
      
      (define/override (get-dc)
        b-dc
      )
      
      ; the selected node
      (define selected-node #f)
      ; the nodes in the graph, nodes are identified by an integer number
      (define nodes (make-hash-table 'equal))
      ; the maximum id number in the hash table
      (define max-id 0)
      
;      ; the edge in the graph, indexed by source tabs
;      (define line-src (make-hash-table 'equal))
;      ; the edge in the graph, indexed by destination tabs
;      (define line-dst (make-hash-table 'equal))
      
      (public get-selected)
      (define (get-selected)
        selected-node
      )
      
      (define (distance x1 y1 x2 y2)
        (let
          ((dx (- x2 x1))
           (dy (- y2 y1)))
          (sqrt (+ (* dx dx) (* dy dy)))
        )
      )
      
      (define (is-inside? x1 y1 x2 y2 x y)
        (and (<= (min x1 x2) x (max x1 x2))
             (<= (min y1 y2) y (max y1 y2)))
      )
      
      (define (overlap? x1 y1 w1 h1
                        x2 y2 w2 h2)
        (let
          ((halfw1 (* 0.5 w1))
           (halfh1 (* 0.5 h1))
           (halfw2 (* 0.5 w2))
           (halfh2 (* 0.5 h2))
          )
          (or (is-inside? (- x2 halfw2) (- y2 halfh2) (+ x2 halfw2) (+ y2 halfh2)
                          (- x1 halfw1) (- y1 halfh1))
              (is-inside? (- x2 halfw2) (- y2 halfh2) (+ x2 halfw2) (+ y2 halfh2)
                          (+ x1 halfw1) (- y1 halfh1))
              (is-inside? (- x2 halfw2) (- y2 halfh2) (+ x2 halfw2) (+ y2 halfh2)
                          (+ x1 halfw1) (+ y1 halfh1))
              (is-inside? (- x2 halfw2) (- y2 halfh2) (+ x2 halfw2) (+ y2 halfh2)
                          (- x1 halfw1) (+ y1 halfh1))
              ;;;;;
              (is-inside? (- x1 halfw1) (- y1 halfh1) (+ x1 halfw1) (+ y1 halfh1)
                          (- x2 halfw2) (- y2 halfh2))
              (is-inside? (- x1 halfw1) (- y1 halfh1) (+ x1 halfw1) (+ y1 halfh1)
                          (+ x2 halfw2) (- y2 halfh2))
              (is-inside? (- x1 halfw1) (- y1 halfh1) (+ x1 halfw1) (+ y1 halfh1)
                          (+ x2 halfw2) (+ y2 halfh2))
              (is-inside? (- x1 halfw1) (- y1 halfh1) (+ x1 halfw1) (+ y1 halfh1)
                          (- x2 halfw2) (+ y2 halfh2))
          )
        )
      )
      
      ; this function enforces the node placement strategy, so
      ; the nodes cannot overlap
      (define (layout-aux id)
        (let ((ok? #t)
              (n max-id)
              (anode (hash-table-get nodes id #f)))
          ; maybe anode does not exist
          (do ((i 0 (+ i 1))) ((or anode (= i n)))
            (set! id i)
            (set! anode (hash-table-get nodes id #f))
          )
          (if anode
            (let-values
              (((ax ay) (send anode get-position))
               ((aw ah) (send anode get-size)))
              (do ((j 0 (+ j 1))) ((= j n))
                (if (not (= j id))
                  (let
                    ((bnode (hash-table-get nodes j #f)))
                    (if bnode
                      (let-values
                        (((bx by) (send bnode get-position))
                         ((bw bh) (send bnode get-size))
                        )
                        (if (overlap? ax ay aw (+ ah tab-height tab-height)
                                      bx by bw (+ bh tab-height tab-height))
                          (begin
                            (send bnode x-set! (+ ax (+ (* aw 0.55) (* bw 0.55)) node-buffer))
                            (layout-aux j))))))))))))
      (public layout)
      (define (layout id)
        (layout-aux id)
        (update-bitmap)
        (on-paint)
      )
      
      (public clear)
      (define (clear)
        (let 
          ((allowed? (if callback (callback 'before-clear #f) #t)))
          (if allowed?
            (begin
              (set! nodes    (make-hash-table 'equal))
;              (set! line-src (make-hash-table 'equal))
;              (set! line-dst (make-hash-table 'equal))
              (layout #f)
              (if callback
                (callback 'after-clear #f)
              )
            )
          )
        )
      )
      
      (public node-add)
      (define (node-add name x y style)
        (let 
          ((allowed? (if callback (callback 'before-node-add name) #t)))
          (if allowed?
            ; store new node
            (let*
              ((id max-id)
               (node (new node% 
                          (id id) (name name) 
                          (x x) (y y) 
                          (editor this) (style style))))
              ; add to the hash table
              (hash-table-put! nodes id node)
              ; increment the maximum id number
              (set! max-id (+ max-id 1))
              ; ensure that the node is not outside of screen
              (let-values
                (((w h) (send node get-size)))
                (if (< x 0)
                  (send node x-set! (* w 0.5))
                )
                (if (< y 0)
                  (send node y-set! (* 0.5 (+ h tab-height tab-height)))
                )
              )
              ; do a full layout
              (layout id)
              (if callback
                (callback 'after-node-add node)
              )
              node
            )
            #f
          )
        )
      )
      
      (public node-del)
      (define (node-del node)
        (if (and (not (send node tab-in-connected?))
                 (not (send node tab-out-connected?)))
          (let 
            ((allowed? (if callback (callback 'before-node-del node) #t)))
            (if allowed?
              ; delete the node
              (let*
                ((id (send node get-id)))
                (hash-table-remove! nodes id)
                ; ensure that it all of them are unselected
                (set! selected-node #f)
                ; do a full layout
                (layout #f)
                (if callback
                  (callback 'after-node-del id)
                )
              )
            )
          )
        )
      )
      
      (public node-get-by-name)
      (define (node-get-by-name name)
        (let ((ok? #f)
              (n max-id))
          (do ((i 0 (+ i 1))) ((or ok? (= i n)))
            (let ((node (hash-table-get nodes i #f)))
              (if (and node
                       (equal? (send node get-name) name))
                (set! ok? node))))
          ok?
        )
      )
      
      ; func has two arguments
      ; key : (an integer number)
      ; value : a node object
      (public node-for-each)
      (define (node-for-each func)
        (hash-table-for-each
          nodes
          func
        )
      )
      
      (public node-del!)
      (define (node-del! node)
            (let
              ((ni (send node tab-in-count))
               (no (send node tab-out-count)))
              ; go through the input tabs and delete connected lines
              (do ((i 0 (+ i 1))) ((= i ni))
                (let ((tab (send node tab-in-ref i)))
                  (if (send tab connected?)
                    ; if lines are conencected to tab then delete the lines
                    (for-each
                      (lambda (line)
                        (let
                          ((src (send line get-source))
                           (dst (send line get-target)))
                          (line-del line src dst)))
                      (send tab get-lines)))))
              ; go through the output tabs and delete connected lines
              (do ((i 0 (+ i 1))) ((= i no))
                (let ((tab (send node tab-out-ref i)))
                  (if (send tab connected?)
                    ; if lines are conencected to tab then delete the lines
                    (for-each
                      (lambda (line)
                        (let
                          ((src (send line get-source))
                           (dst (send line get-target)))
                          (line-del line src dst)))
                      (send tab get-lines)))))
              ; delete the node itself
              (node-del node)
            )
      )
      
      ; it returns the line object
      (public line-add)
      (define (line-add src-tab dst-tab)
        (let
          ((allowed? (if callback (callback 'before-line-add (list src-tab dst-tab)) #t)))
          (if allowed?
            (let
              ((line (make-object line% src-tab dst-tab this))
;               (src-lst (hash-table-get line-src src-tab #f))
;               (dst-lst (hash-table-get line-dst dst-tab #f))
              )
;              (if src-lst
;                (hash-table-put! line-src src-tab (cons line src-lst))
;                (hash-table-put! line-src src-tab (list line))
;              )
;              (if dst-lst
;                (hash-table-put! line-dst dst-tab (cons line dst-lst))
;                (hash-table-put! line-dst dst-tab (list line))
;              )
              (send src-tab line-add line)
              (send dst-tab line-add line)
              (send line show)
              (if callback
                (callback 'after-line-add line)
              )
              (on-paint)
              line
            )
            #f
          )
        )
      )
      
      (define (line-del line src-tab dst-tab)
        (let
          ((allowed? (if callback (callback 'before-line-del (list src-tab dst-tab)) #t)))
          (if allowed?
            (let*
              (
;               (src-lst  (hash-table-get line-src src-tab #f))
;               (dst-lst  (hash-table-get line-dst dst-tab #f))
;               (src-rest (remove line src-lst))
;               (dst-rest (remove line dst-lst))
              )
;              (if (null? src-rest)
;                (hash-table-remove! line-src src-tab)
;                (hash-table-put! line-src src-tab src-rest)
;              )
;              (if (null? dst-rest)
;                (hash-table-remove! line-dst dst-tab)
;                (hash-table-put! line-dst dst-tab dst-rest)
;              )
              (send src-tab line-del line)
              (send dst-tab line-del line)
              (send line hide)
              (if callback 
                (callback 'after-line-del #f)
              )
              (on-paint)
            )
          )
        )
      )
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      ; get the real width of the network
      (define (get-real-width)
        (let
          ((width 0))
          (hash-table-for-each
            nodes
            (lambda (idx node)
              (let-values
                (((x y) (send node get-position))
                 ((w h) (send node get-size)))
                (set! width (max width (+ x (* w 0.5))))
              )
            )
          )
          (inexact->exact (round width))
        )
      )
      
      (define (get-real-height)
        (let
          ((height 0))
          (hash-table-for-each
            nodes
            (lambda (idx node)
              (let-values
                (((x y) (send node get-position))
                 ((w h) (send node get-size)))
                (set! height (max height (+ y (* (+ h tab-height tab-height) 0.5))))
              )
            )
          )
          (inexact->exact (round height))
        )
      )
      
      (define (update-bitmap)
        (update-scroll-bars)
        ;; We will need the virtual size...
        (let-values (((width height) (send this get-virtual-size)))
          ;; We create a bitmap, with the *real* width and height (at least, if they are
          ;; greater than the virtual width and height...), 
          ;; in order to be able to scroll very quickly...
          (let*
            ((w (max (get-real-width) width 1))
             (h (max (get-real-height) height 1)))
            (if (or (not bitmap)
                    (> w bitmap-width)
                    (> h bitmap-height))
              (let*
                ((n (round (max (/ w 1000) (/ h 1000))))
                 (size (* (+ n 1) 1000)))
                (set! bitmap (make-object bitmap% size size #f))
                ;; And then, we update the associated bitmap-dc...
                (set! b-dc (instantiate bitmap-dc% (bitmap)))
                (set! bitmap-width size)
                (set! bitmap-height size)
                (on-paint)
              )
            )
          )
        )
      )
      
      ;; This function updates the scroll bars properties for update-bitmap
      (define (update-scroll-bars)
        (let
          ((horizontal? #f) (vertical? #f))
          ;; hide both of the scroll bars
          (send this show-scrollbars #f #f)
          ;; We need to get the virtual size...
          (let-values (((width height) (send this get-virtual-size)))
            ;; Then, we update the scroll range for both the horizontal and 
            ;; the vertical scroll bars. 
            ;; The right range is the full real height (width, respectively) minus the
            ;; virtual height (resp. width).
            ;; vertical scrollbar
            (send this set-scroll-range 'vertical (max 0 (- (get-real-height) height)))
            ;; If the window can contain the whole height, no y offset is needed.
            (if (= 0 (send this get-scroll-range 'vertical)) 
              (set! y-offset 0)
              (begin
                (send this show-scrollbars #f #t)
                (set! vertical? #t)
              )
            )
          )
          (let-values (((width height) (send this get-virtual-size)))
            ;; horizontal scrollbar
            (send this set-scroll-range 'horizontal (max 0 (- (get-real-width) width)))
            ;; If the window can contain the whole width, no x offset is needed.
            (if (= 0 (send this get-scroll-range 'horizontal))
              (set! x-offset 0) 
              (begin
                (send this show-scrollbars #t vertical?)
                (set! horizontal? #t)
              )
            )
          )
          (let-values (((width height) (send this get-virtual-size)))
            ;; check vertical scrolling again
            (send this set-scroll-range 'vertical (max 0 (- (get-real-height) height)))
            ;; If the window can contain the whole height, no y offset is needed.
            (if (= 0 (send this get-scroll-range 'vertical))
              (set! y-offset 0)
              (send this show-scrollbars horizontal? vertical?)
            )
            ;; This is the number of scroll steps - 
            ;; vertically we want to scroll not exactly one page, 
            ;; but one page minus one line (as it is always implemented).
            (send this set-scroll-page 'horizontal (max 1 width))
            (send this set-scroll-page 'vertical (max 1 (- height vertical-scroll-step)))
          )
        )
      )
      
      (define/override (on-scroll scroll-event)
        ;; What we are going to do depends on the event direction...
        (case (send scroll-event get-direction)
          ;; Is it vertical?
          ((vertical) 
           ;; Then it depends on the event type...
           (let ((type (send scroll-event get-event-type)))
             ;; If the event type is line down...
             (cond 
               ((eq? type 'line-down)
                ;; ...then we need the virtual size...
                (let-values (((width height) (send this get-virtual-size)))
                  ;; ...update the scroll-bars positions 
                  ;; (to force scrolling more than 1 step [1 line, actually])...
                  (send this set-scroll-pos 'vertical 
                        (min (+ (send this get-scroll-pos 'vertical) vertical-scroll-step -1) 
                             (send this get-scroll-range 'vertical)))
                  ;; ...and the vertical offset.
                  (set! y-offset (min (+ y-offset vertical-scroll-step) 
                                      (send this get-scroll-range 'vertical)))))
                 
               ;; If the event type is line-up...
               ((eq? type 'line-up)
                ;; ...then we update the scroll-bars positions 
                ;; (to force scrolling more than 1 step...)...
                (send this set-scroll-pos 'vertical 
                      (max (- (send this get-scroll-pos 'vertical) vertical-scroll-step -1) 0))
                ;; ...and the vertical offset.
                (set! y-offset (max (- y-offset vertical-scroll-step) 0)))
                
               ;; Otherwise, we do not have to update the scroll-bars positions, 
               ;; just to update the vertical offset...
               (else (set! y-offset (send scroll-event get-position))))))
        
          ;; Is it horizontal?
          ((horizontal) 
           ;; Then it depends on the event type...
           (let ((type (send scroll-event get-event-type)))
             ;; If the event type is line down...
             (cond 
               ((eq? type 'line-down)
                ;; ...then we need the virtual size...
                (let-values (((width height) (send this get-virtual-size)))
                  ;; ...update the scroll-bars positions 
                  ;; (to force scrolling more than 1 step... [1 "horizontal scroll step", actually])...
                  (send this set-scroll-pos 'horizontal 
                        (min (+ (send this get-scroll-pos 'horizontal) horizontal-scroll-step -1) 
                                (send this get-scroll-range 'horizontal)))
                  ;; ...and the horizontal offset.
                  (set! x-offset (min (+ x-offset horizontal-scroll-step) 
                                      (send this get-scroll-range 'horizontal)))))
                 
               ;; If the event type is line-up...
               ((eq? type 'line-up)
                ;; ...then we update the scroll-bars positions 
                ;; (to force scrolling more than 1 step...)...
                (send this set-scroll-pos 'horizontal 
                      (max (- (send this get-scroll-pos 'horizontal) horizontal-scroll-step -1) 0))
                ;; ...and the horizontal offset.
                (set! x-offset (max (- x-offset horizontal-scroll-step) 0)))
                 
               ;; Otherwise, we do not have to update the scroll-bars positions, 
               ;; just to update the horizontal offset...
               (else (set! x-offset (send scroll-event get-position)))))))
      
        ;; And then, we directly draw the bitmap, which has already been drawn during the last
        ;; call of (on-paint), at the right position - which is *much* faster than calling on-paint
        ;; directly and allows a smooth scrolling.
        (let
          ((dc (super get-dc)))
          (send dc draw-bitmap bitmap (- x-offset) (- y-offset))
        )
      )
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; on-size
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      (define/override (on-size width height)
        ;; We just update the bitmap...
        (update-bitmap)
      )
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; on-paint
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      (define (refresh)
        (if (send bitmap ok?)
          (let
            ((dc (super get-dc)))
            (send dc draw-bitmap bitmap (- x-offset) (- y-offset))
          )
        )
      )
      
      ; redrawing event
      (define/override (on-paint)
        (let
          ((dc (get-dc))
           (n  max-id)
          )
          ; clear the background
          (send dc set-background (get-panel-background))
          (send dc clear)
          ; draw all nodes with tabs and lines
          (do ((i 0 (+ i 1))) ((= i n))
            (let
              ((node (hash-table-get nodes i #f)))
              (if node
                (if (equal? node selected-node)
                  (send node show #t)
                  (send node show #f)
                )
              )
            )
          )
        )
        ; draw the bitmap
        (refresh)
      )
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; on-char
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      (define/override (on-subwindow-char widget event)
        (let
          ((key (send event get-key-code))
           (ctrl (send event get-control-down))
          )
          (cond
            ((equal? key #\rubout)
             (let
               ((node selected-node))
               (if (and node 
                        (not (send node tab-in-connected?))
                        (not (send node tab-out-connected?)))
                 (node-del node)
               )
             )
            )
          )
        )
      )
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; on-event
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      (define clicked #f)
      (define px #f)
      (define py #f)
      
      (define (find-clicked type x y)
        (let
          ((obj #f))
          ; go through all nodes
          (hash-table-for-each
            nodes
            (lambda (name node)
              (let
                ((selected (send node on-mouse type x y)))
                (cond
                  ((is-a? selected node%)
                   (set! obj selected)
                  )
                  ((is-a? selected tab%)
                   (set! obj selected)
                  )
                )
              )
            )
          )
          obj
        )
      )
      ; mouse event
      (define/override (on-event event)
        (send this focus)
        (let
          ((type (send event get-event-type))
           (x    (+ (send event get-x) x-offset))
           (y    (+ (send event get-y) y-offset))
          )
          (cond
            ; left button clicked
            ((equal? type 'left-down)
             (set! clicked (find-clicked type x y))
             (if (not clicked)
               (begin
                 (if selected-node
                   (begin
                     (if callback
                       (callback 'deselect selected-node)
                     )
                     (send selected-node show #f)
                     ; we have to refresh only one node
                     (refresh)
                   )
                 )
                 (set! selected-node #f)
               )
             )
            )
            ; out tab is clicked and dragging
            ((and (equal? type 'motion)
                  clicked
                  (is-a? clicked tab%)
                  (equal? (send clicked get-type) 'out))
             (let-values
               (((sx sy) (send clicked get-line-position)))
               (let
                 ((dc (get-dc)))
                 (send dc set-pen "black" 1 'xor)
                 (if (and px py)
                   (send dc draw-line sx sy px py)
                 )
                 (send dc draw-line sx sy x y)
                 ; we have to refresh only the bitmap
                 (refresh)
                 (set! px x)
                 (set! py y)
               )
             )
            )
            ; out tab is clicked and finished dragging
            ((and (equal? type 'left-up)
                  clicked
                  (is-a? clicked tab%)
                  (equal? (send clicked get-type) 'out))
             ; xoring the last line is not required as we will do a full repaint
             ; check to add line
             (let
               ((dest (find-clicked type x y)))
               ; if there is a destination, it is an tab and its type is 'in'
               (if (and dest
                        (is-a? dest tab%)
                        (equal? (send dest get-type) 'in)
                   )
                 (if (not (send dest connected?))
                   (line-add clicked dest)
                   (message-box "Error" "Tab is already connected" #f '(ok stop))
                 )
               )
             )
             ; full redraw
             (on-paint)
             ; clean-up
             (set! clicked #f)
             (set! px #f)
             (set! py #f)
            )
            ; in tab is clicked, a line is connected and dragging
            ((and (equal? type 'motion)
                  clicked
                  (is-a? clicked tab%)
                  (equal? (send clicked get-type) 'in)
                  (send clicked connected?))
             (let*
               ((line (car (send clicked get-lines)))
                (src (send line get-source)))
               ; hide the line
               (send line hide)
               (let-values
                 (((sx sy) (send src get-line-position)))
                 (let
                   ((dc (get-dc)))
                   (send dc set-pen "black" 1 'xor)
                   (if (and px py)
                     (send dc draw-line sx sy px py)
                   )
                   (send dc draw-line sx sy x y)
                   ; we have to refresh only the bitmap
                   (refresh)
                   (set! px x)
                   (set! py y)
                 )
               )
             )
            )
            ; in tab is clicked and finished dragging
            ((and (equal? type 'left-up)
                  clicked
                  (is-a? clicked tab%)
                  (equal? (send clicked get-type) 'in)
                  (send clicked connected?))
             (let*
               ((line (car (send clicked get-lines)))
                (src (send line get-source))
                (dst (send line get-target))
               )
               ; xoring the last line is not required as we will do a full repaint
               ; check to remove line
               (let
                 ((new-dst (find-clicked type x y)))
                 (cond
                   ((equal? new-dst dst)
                    (send line show)
                   )
                   ; there is a new destination, it is an 'in' tab
                   ((and new-dst
                         (is-a? new-dst tab%)
                         (equal? (send new-dst get-type) 'in))
                    ; first delete the previous line
                    (line-del line src dst)
                    ; then add the line between the old source and new destination
                    (line-add src new-dst)
                   )
                   (else
                    (line-del line src dst)
                   )
                 )
               )
               ; full redraw
               (on-paint)
               ; clean-up
               (set! clicked #f)
               (set! px #f)
               (set! py #f)
             )
            )
            ; node is clicked and dragging
            ((and (equal? type 'motion)
                  clicked
                  (is-a? clicked node%))
             (if (send clicked is-shown?)
               (send clicked hide #f)
             )
             (let-values
               (((sw sh) (send clicked get-size)))
               (let
                 ((dc (get-dc)))
                 (send dc set-pen "black" 1 'xor)
                 (send dc set-brush "black" 'xor)
                 (if (and px py)
                   (send dc draw-rectangle 
                         (- px (* sw 0.5)) (- py (* sh 0.5))
                         sw sh)
                 )
                 (send dc draw-rectangle 
                       (- x (* sw 0.5)) (- y (* sh 0.5))
                       sw sh)
                 ; we have to refresh only the bitmap
                 (refresh)
                 (set! px x)
                 (set! py y)
               )
             )
            )
            ; node is clicked and finished dragging
            ((and (equal? type 'left-up)
                  clicked
                  (is-a? clicked node%))
             ; hiding the dragged square is not necessary, we will do a full redraw
             ; do a layout if there was a dragging
             (if (and px py)
               (let-values
                 (((w h) (send clicked get-size)))
                 ; ensure that no negative coordinates are allowed
                 (if (< x 0)
                   (send clicked x-set! (* w 0.5))
                   (send clicked x-set! x)
                 )
                 (if (< y 0)
                   (send clicked y-set! (* 0.5 (+ h tab-height tab-height)))
                   (send clicked y-set! y)
                 )
                 (layout (send clicked get-id))
               )
             )
             (send clicked show #t)
             (set! selected-node clicked)
             (if callback
               (callback 'select selected-node)
             )
             ; full redraw
             (on-paint)
             (set! clicked #f)
             (set! px #f)
             (set! py #f)
            )
            
          )
        )
      )
      
      (super-new (style '(vscroll hscroll border)))
      
      (update-bitmap)
      (send (send this get-dc) set-font font)
    )
  )
  
); end of module




