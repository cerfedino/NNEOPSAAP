;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-advanced-reader.ss" "lang")((modname Player) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #t #t none #f () #f)))

;Libraries
(require racket/class)
(require racket/base)
(require 2htdp/image)

;Classes
(require "Bullet.rkt")
(require "Sprite.rkt")
(require "../resources/media.rkt")


;Step 1: Data types

; a bulletconf is a structure (make-bulletconf an-Image a-Posn posn-offset a-SpeedStruct ))
;    where an-Image    : Image
;          a-Posn      : Posn
;             initial position of the bullet
;          posn-offset :  Posn
;             offset of the bullet related to the player's position
;          a-SpeedStruct : Posn
;             speed of the bullet          
; Interpretation: Represents a configuration setup for a bullet. When the player shoots, %bullet objects get created based on these bulletconf structs

(define-struct bulletconf
  [an-Image a-Posn posn-offset a-SpeedStruct] #:mutable)
;Data examples
(define BC1 (make-bulletconf
              LASERBEAM-IMG
              (make-posn -1 -1)
              (make-posn 0 0)
              (make-posn 0 -15)))
(define BC2 (make-bulletconf
              LASERBEAM-IMG
              (make-posn -1 -1)
              (make-posn 30 0)
              (make-posn 25 15)))
;Step 1: Data types

; a upgrades is a structure (make-upgrades speedMul front diagonal ))
;    where speedMul   : Number
;             The speed multiplier for the bullets
;          front      : Number
;             The number of frontal bullets shot everytime
;          diagonal   : Number
;             The number of diagonal bullets that get shot everytime
; interpretation: Keeps track of the player upgrades. Everytime the player picks up an upgrade these stats increase.

(define-struct upgrades
  [speedMul front diagonal] #:mutable)
; Data examples
(define UPG1 (make-upgrades 1 1 0))
(define UPG2 (make-upgrades 2 5 5))

(define player% (class sprite%
                  
                  ; Input parameters to give on creation of a %player object
                  (init an-Image playerName a-Posn startingLifes)
                  (super-new (an-Image an-Image)(a-Posn a-Posn)(a-SpeedStruct (make-posn 0 0)))

                  ; PLAYER FIELDS
                  
                  ; name of the player
                  (field (name playerName))
                  ; score of the player
                  (field (score 0))
                  ; the full player lifes
                  (field (starting-lifes startingLifes))
                  ; current player lifes
                  (field (lifes startingLifes))
                  ; Player upgrades
                  (field (upgrades (make-upgrades 1 1 0)))
                  ; Contains the configurations for the bullets that get shot on (shoot)
                  (field (shooting-pattern
                         (list
                            ;; Front bullets
                            (list
                              (make-bulletconf
                                  LASERBEAM-IMG
                                  (make-posn -1 -1)
                                  (make-posn 0 0)
                                  (make-posn 0 -15)))
                            ;; Side bullets
                            (list ))))

                  

                  
; Step 2 . Input/Output

; Signature: increase-score : Number -> (void)
; Purpose Statement: Increases the score of the player by a certain amount
; Header/Stub (define/public (increase-score amount) (void))

;Step 4 . Template

; (define/public (increase-score amount)
;                    (set! score (... score ...)))

;Step 5 . Code
  
                  (define/public (increase-score amount)
                    (set! score (+ score amount)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  
; Step 2 . Input/Output

; Signature: shoot :  -> List<%bullet>
; Purpose Statement: Called when the player shoots. Plays the shooting sfx and returns the list of the bullets just shot.
; Header/Stub (define/public (shoot) (list (new bullet% ....)))

;Step 4 . Template

;    (define/public (shoot)
;                    (LASERBEAM_SFX)
;                    (local
;                      ((define position ...)
;                      (define (extractBullets list)
;                        (map (lambda (x)
;                             (new bullet%
;                                  (...an-Image ...)
;                                  (...a-Posn... )
;                                  (...a-SpeedStruct...  ))
;                           ...)))
;                      (append... ))))

;Step 5 . Code
                                            
               (define/public (shoot)
                    (LASERBEAM_SFX)
                    (local
                      ((define position (get-field position this))
                      (define (extractBullets list)
                        (map (lambda (x)
                             (new bullet%
                                  (an-Image (bulletconf-an-Image x))
                                  (a-Posn (make-posn (+ (posn-x position)(*(posn-x (bulletconf-posn-offset x)) screenScale)) (+ (posn-y position)(*(posn-y (bulletconf-posn-offset x)) screenScale)) ) )
                                  (a-SpeedStruct (make-posn (* (posn-x (bulletconf-a-SpeedStruct x))(upgrades-speedMul upgrades)) 
                                                            (* (posn-y (bulletconf-a-SpeedStruct x))(upgrades-speedMul upgrades)))) ))
                           list)))
                      (append (extractBullets (list-ref shooting-pattern 0))(extractBullets (list-ref shooting-pattern 1)))))
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: decrease-lifes :  -> (void)
; Purpose Statement: Decreases the player lifes by 1
; Header/Stub (define/public (decrease-lifes lifes) (void))

;Step 4 . Template

;(define/public (decrease-lifes)
;                    (set!... (...)))

;Step 5 . Code                  
                 
                 (define/public (decrease-lifes)
                    (set! lifes (- lifes 1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: increase-lifes :  -> (void)
; Purpose Statement: Increases the player lifes by 1
; Header/Stub (define/public (increase-lifes lifes) (void))

;Step 4 . Template

;(define/public (decrease-lifes)
;                    (set!... (...)))

;Step 5 . Code 
                  
                  (define/public (increase-lifes)
                    (set! lifes (+ lifes 1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: 
;     hit :  -> (void)
;         called when the player takes damage
;     heal :  -> (void)
;         called when the player heals
; Header/Stub 
;     (define/public (hit) (void))
;     (define/public (heal) (void))

;Step 5 . Code 
                  (define/public (hit)
                    (PLAYER_HIT_SFX)
                    (decrease-lifes))
                  (define/public (heal)
                    (PLAYER_HEAL_SFX)
                    (increase-lifes))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                 
;Step 2. Input/output

; Signature: 
;     add-upgrade : %upgrade -> (void)
; Purpose Statement: 
;     Extracts the name of the %upgrade given in input and adds it to player
; Header/Stub 
;     (define/public (add-upgrade upgrade) (void))

;Step 4 . Template
;(define/public (add-upgrade upgrade)
;  (local
;    ((define UPG-NAME (get-field name upgrade)))
;    (cond
;      [(string=? UPG-NAME "life")     (...)]
;      [(string=? UPG-NAME "speedMul") (...)]
;      [(string=? UPG-NAME "front")    (...)]
;      [(string=? UPG-NAME "diagonal") (...)]
;      [else (void) ])))

;Step 5 . Code                
                  (define/public (add-upgrade upgrade)
                    (local
                      ((define UPG-NAME (get-field name upgrade)))
                      (cond
                        [(string=? UPG-NAME "life") (heal)]
                        [(string=? UPG-NAME "speedMul") (PLAYER_UPGRADE_SFX)(addSpeedMul-upgrade)]
                        [(string=? UPG-NAME "front") (PLAYER_UPGRADE_SFX)(addFront-upgrade)]
                        [(string=? UPG-NAME "diagonal") (PLAYER_UPGRADE_SFX)(addDiagonal-upgrade)]
                        [else (void) ])))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: 
;   addSpeedMul-upgrade :  -> (void)
; Purpose Statement: 
;   Called when the player collects a 'speed multiplier' upgrade. Increases the value in struct 'upgrades'
; Header/Stub: 
;   (define/private (addSpeedMul-upgrade) (void))

;Step 4 . Template
;(define/private (addSpeedMul-upgrade)
;                      (set-upgrades-speedMul! (+ ... 0.40)))

;Step 5 . Code             
(define/private (addSpeedMul-upgrade)
                      (set-upgrades-speedMul! upgrades (+ (upgrades-speedMul upgrades) 0.40)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Step 2 . Input/Output

; Signature: 
;   addFront-upgrade :  -> (void)
; Purpose Statement: 
;   Called when the player collects a 'front' upgrade. Increases the value in struct 'upgrades'.
;   generates the new list of bulletconf 's for the front bullets
; Header/Stub: 
;   (define/private (addFront-upgrade) (void))

;Step 4 . Template

; (define/private (addFront-upgrade)
;                      (set-upgrades-front! ... (...) ...))
;                      (local
;                        ((define n_frontBullets (upgrades-front upgrades))
;                          (define offset (...)
;                          (define (genBullConf n offset side)
;                            (cond
;                              [(zero? n) '()]
;                              [(positive? n) (cons (make-bulletconf
;                                                      LASERBEAM-IMG
;                                                      ...)
;                                                   (genBullConf (... n..) offset (... side...)))])))
;                        (set! shooting-pattern (list (cond
;                                                        [(odd? n_frontBullets) (append ...)]
;                                                        [else (genBullConf n_frontBullets ... ...)])
;                                                      (list-ref ... ...)))) )

;Step 5 . Code             

                    

                    (define/private (addFront-upgrade)
                      ; Increases the number of front bullets
                      (set-upgrades-front! upgrades (+ (upgrades-front upgrades) 1))
                      (local
                        ((define n_frontBullets (upgrades-front upgrades))
                          ; Calculates the offset of the front bullets based on the amount and the width of the player's %sprite image. This way the bullets equally share the space
                          (define offset (/ (/(image-width (get-field image this))2) (/(- n_frontBullets (modulo n_frontBullets 2))2) ))
                          
                          ; Generates the new list of bulletconf for frontal bullets
                          (define (genBullConf n offset side)
                            (cond
                              [(zero? n) '()]
                              [(positive? n) (cons (make-bulletconf
                                                      LASERBEAM-IMG
                                                      (make-posn -1 -1)
                                                      ; Sets the offset in a way to have half of the bullets positioned on the left and on the right
                                                      (make-posn (* offset side (ceiling (/ n 2))) 0)
                                                      (make-posn 0 -15))

                                                   (genBullConf (- n 1) offset (* side -1)))])))

                        (set! shooting-pattern (list (cond
                                                        [(odd? n_frontBullets) (append (genBullConf 1 0 1) (genBullConf  (- n_frontBullets 1) offset 1))]
                                                        [else (genBullConf n_frontBullets offset 1)])
                                                      (list-ref shooting-pattern 1)))) )


; Step 2 . Input/Output

; Signature: 
;   addDiagonal-upgrade :  -> (void)
; Purpose Statement: 
;   Called when the player collects a 'diagonal' upgrade. Increases the value in struct 'upgrades'.
;   generates the new list of bulletconf 's for the diagonal bullets
; Header/Stub: 
;   (define/private (addFront-upgrade) (void))

;Step 4 . Template

;(define/public (addDiagonal-upgrade)
;                      (set-upgrades-diagonal! upgrades (... (upgrades-diagonal ...) ...))
;                      (local
;                        ((define n_diagonalBullets (upgrades-diagonal upgrades))
;                          (define offset (...) ))
;                          (define (genBullConf n offset side)
;                            (cond
;                              [(zero? ...) '()]
;                              [(positive? n) (cons (...)
;                                                (cons (...)
;                                                   (genBullConf (... n ...) offset (... side ...))))])))
;
;                        (set! shooting-pattern (list (list-ref shooting-pattern ...)
;                                                     (cond
;                                                        [(odd? n_diagonalBullets) (append ...)]
;                                                        [else (genBullConf n_diagonalBullets offset ...)])))))

;Step 5 . Code 
                  

                    (define/public (addDiagonal-upgrade)                      
                    ; Increases the number of diagonal bullets
                      (set-upgrades-diagonal! upgrades (+ (upgrades-diagonal upgrades) 1))

                      (local
                        ((define n_diagonalBullets (upgrades-diagonal upgrades))
                          ; Calculates the offset of the diagonal bullets based on the amount and the width of the player's %sprite image. This way the bullets equally share the space
                          (define offset (/ (/(image-height SPACESHIP1-IMG)2) (/ n_diagonalBullets 2) ))

                          ; Generates the new list of bulletconf for diagonal bullets
                          (define (genBullConf n offset side)
                            (cond
                              [(zero? n) '()]
                              [(positive? n) (cons (make-bulletconf
                                                    LASERBEAM-IMG
                                                    (make-posn -1 -1)
                                                    (make-posn (/(image-height SPACESHIP1-IMG)2) (* offset side (ceiling (/ n 2))))
                                                    (make-posn 25 -15))
                                                (cons (make-bulletconf
                                                       LASERBEAM-IMG
                                                       (make-posn -1 -1)
                                                       (make-posn (* (/(image-height SPACESHIP1-IMG)2)-1) (* offset side (ceiling (/ n 2))))
                                                       (make-posn -25 -15))

                                                   (genBullConf (- n 1) offset (* side -1))))])))

                        (set! shooting-pattern (list (list-ref shooting-pattern 0)
                                                     (cond
                                                        [(odd? n_diagonalBullets) (append (genBullConf 1 0 1) (genBullConf  (- n_diagonalBullets 1) offset 1))]
                                                        [else (genBullConf n_diagonalBullets offset 1)])))))
                  ))

; Makes the class available to any .rkt file that requires this file 
(provide player%)

; (define pl (new player% (an-Image (rectangle 40 40 "solid" "green"))(playerName "TheLegend64") (a-Posn (make-posn -10 0)) (startingLifes 3)))