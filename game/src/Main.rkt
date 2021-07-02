;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Main) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))
;Libraries

(require racket/gui) 
(require 2htdp/universe)
(require racket/base)
(require racket/class)
(require "game.rkt")
(require "resources/media.rkt")
(require pict)


; Step 1. Data types
; a main-frame is an object of class frame% (new frame% label width height style alignment))
;    where label     : String
;          width     : Number
;          height    : Number
;          style     : panel%
;          alignment : Posn
; interpretation: a class that holds the GUIs elements

(define main-frame (new frame%
                       [label "Asteroid"]
                       [width (ceiling (* 900 screenScale))]
                       [height (ceiling (* 700 screenScale))]
                       [style '(no-resize-border)]
                       [alignment '(center top)]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Step 2 . Input/Output

; Signature: LOGO-PNG : Image -> Image
; Purpose Statement: ;convert picture to bitmap so it can be instatntiated by canvas
; Header/Stub: (define LOGO-PNG pict) pict)

;Step 4 . Template

;(define LOGO-PNG
;  (pict->bitmap  (scale (... "resources/img/logo.png"...) (... ... screenScale) ))) 


; Step 5 . Code

(define LOGO-PNG
  (pict->bitmap  (scale (bitmap "resources/img/logo.png") (* 2.5 screenScale) ))) 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a canvas is an object of class canvas% (new canvas% parent main-frame))
;    where parent         : an objext of class panel%
;          paint-callback : procedure
; interpretation: It represents a canvas that handles events in the main-frame


(define canvas (new canvas%
                    [parent main-frame]
                    [paint-callback (lambda
                                        (canvas dc) (send dc draw-bitmap LOGO-PNG (ceiling (* 170 screenScale)) (ceiling (* -30 screenScale))))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Main-frame buttons

; Step 1. Data types
; a button% is a class (new button% parent label vert-margin font callback))
;    where parent      : an objext of class panel%
;          label       : String
;          vert-margin : Number
;          font        : object of class font%
;          callback    : procedure for a button click
; interpretation: function executed on interaction with the GUI element

(new button% [parent main-frame]
             [label " Start game"]
             [vert-margin (ceiling (* 10 screenScale))]
             [font (make-object font% 10 'modern 'normal )]
             [callback (lambda
                           (btn ev) (CLICK_SFX) (send sub-frame show #t))])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a button% is a class (new button% parent label vert-margin font callback))
;    where parent      : an objext of class panel%
;          label       : String
;          vert-margin : Number
;          font        : object of class font%
;          callback    : procedure for a button click
; interpretation: It represents a button in the frame
(new button% [parent main-frame]
             [label "How to play"]
             [font (make-object font% 10 'modern 'normal )]
             [vert-margin (ceiling (* 10 screenScale))]
             [callback (lambda
                           (btn ev) (CLICK_SFX))])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a button% is a class (new button% parent label vert-margin font callback))
;    where parent      : an objext of class panel%
;          label       : String
;          vert-margin : Number
;          font        : object of class font%
;          callback    : procedure for a button click
; interpretation: It represents a button in the frame.
(new button% [parent main-frame]
             [label "Leaderboard"]
             [font (make-object font% 10 'modern 'normal )]
             [vert-margin (ceiling (* 10 screenScale))]
             [callback (lambda
                           (btn ev) (CLICK_SFX) (leaderboard (void)) )])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a button% is a class (new button% parent label vert-margin font callback))
;    where parent      : an objext of class panel%
;          label       : String
;          vert-margin : Number
;          font        : object of class font%
;          callback    : procedure for a button click
; interpretation: It represents a button in the frame
(new button% [parent main-frame]
             [label "   quit    "]
             [font (make-object font% 10 'modern 'normal )]
             [vert-margin (ceiling (* 10 screenScale))]
             [callback (lambda
                           (btn ev) (CLICK_SFX) (exit))])  
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; Step 1. Data types
; a sub-frame is an object of class frame% (new frame% label width height style ))
;    where label   : String
;          width   : Number
;          height  : Number
;          style   : an object of class panel%
; interpretation: It holds the name-input, Life-input, start-game
(define sub-frame (new frame%
                       [label "Get started"]
                       [width (ceiling (* 500 screenScale))]
                       [height (ceiling (* 300 screenScale))]
                       [style '(no-resize-border)])) 

;--------start of placement of elements in sub-frame------ ????????????????????????????????????
(define row1 (new horizontal-panel%
                  [parent sub-frame]
                  [vert-margin (ceiling (* 10 screenScale))]
                  [stretchable-height #f]))

(define row2 (new horizontal-panel%
                  [parent sub-frame]
                  [stretchable-height #f]))

(define col-1 (new vertical-panel%
                   [parent row1]
                   [min-width (ceiling (* 100 screenScale))]
                   [stretchable-height #t])) 

(define col-2 (new vertical-panel%
                   [parent row2]
                   [min-width (ceiling (* 10 screenScale))]
                   [stretchable-height #t]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a name-input is an object of class text-field% (new text-field% label parent stretchable-width callback))
;    where label       : String
;          parent      : an objext of class panel%
;          stretchable-width   : Boolean(???)
;          callback    : procedure for a button click
; interpretation: it represents the name value inputed by player and sets it as well as enabling the use of the Life-input slider

(define name-input (new text-field%
                        [label "Name"]
                        [parent col-1]
                        [stretchable-width #f]
                        [callback (lambda
                                      (btn ev) (cond
                                                  [(non-empty-string? (string-replace (send name-input get-value) " " "")) (send start-game enable #t)]
                                                  [else (send start-game enable #f)]))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a Life-input is an object of class slider% (new slider% label parent min-value max-value enabled init-value ))
;    where label       : String
;          parent      : an objext of class panel%
;          min-value   : Number
;          max-value   : Number
;          enabled     : Boolean
;          init-value  : Number
; interpretation: it gets the life value inputed by player and sets it as well as enabling the use of start-game

(define Life-input (new slider%
                        [label "Lifes"]
                        [parent col-2]
                        [min-value 1]
                        [max-value 20]
                        [enabled #t]
                        [init-value 3]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 1. Data types
; a start-game is an object of class button% (new button%  parent label  vert-margin enabled horiz-margin callback ))
;    where parent       : an objext of class panel%
;          label        : String
;          vert-margin  : Number
;          enabled      : Boolean
;          horiz-margin : Number
;          callback     :     procedure for a button click          
; interpretation: it starts the game 

(define start-game (new button%
                        [parent sub-frame]
                        [label "Start"]
                        [vert-margin (ceiling (* 10 screenScale))]
                        [enabled #f]
                        [horiz-margin 0]
                        [callback (lambda
                                      (btn ev) (PLAY_SFX) 
                                        (set-field! lifes (AppState-player ASS1) (send Life-input get-value))
                                        (set-field! starting-lifes (AppState-player ASS1) (send Life-input get-value))
                                        (set-field! name (AppState-player ASS1) (send name-input get-value))
                                        (begin (game ASS1)))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;instantiation of the Main-frame with all elements
(send main-frame show #t) 
 