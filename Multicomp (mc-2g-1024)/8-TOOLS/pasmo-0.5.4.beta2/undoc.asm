; undoc.asm
; Test of assembling of undocumented z80 instructions.

	org 100h ; For tests with cp/m

	ld a,ixh
	ld a,ixl
	ld a,iyh
	ld a,iyl

	ld b,ixh
	ld b,ixl
	ld b,iyh
	ld b,iyl

	ld c,ixh
	ld c,ixl
	ld c,iyh
	ld c,iyl

	ld d,ixh
	ld d,ixl
	ld d,iyh
	ld d,iyl

	ld e,ixh
	ld e,ixl
	ld e,iyh
	ld e,iyl

	ld ixh,a
	ld ixh,b
	ld ixh,c
	ld ixh,d
	ld ixh,e
	ld ixh,ixh
	ld ixh,ixl
	ld ixh,20h

	ld ixl,a
	ld ixl,b
	ld ixl,c
	ld ixl,d
	ld ixl,e
	ld ixl,ixh
	ld ixl,ixl
	ld ixl,20h

	ld iyh,a
	ld iyh,b
	ld iyh,c
	ld iyh,d
	ld iyh,e
	ld iyh,iyh
	ld iyh,iyl
	ld iyh,20h

	ld iyl,a
	ld iyl,b
	ld iyl,c
	ld iyl,d
	ld iyl,e
	ld iyl,iyh
	ld iyl,iyl
	ld iyl,20h

	inc ixh
	inc ixl
	inc iyh
	inc iyl
	dec ixh
	dec ixl
	dec iyh
	dec iyl

	add a,ixh
	add a,ixl
	add a,iyh
	add a,iyl

	adc a,ixh
	adc a,ixl
	adc a,iyh
	adc a,iyl

	sbc a, ixh
	sbc a, ixl
	sbc a, iyh
	sbc a, iyl

	sub ixh
	sub ixl
	sub iyh
	sub iyl

	and ixh
	and ixl
	and iyh
	and iyl

	xor ixh
	xor ixl
	xor iyh
	xor iyl

	or ixh
	or ixl
	or iyh
	or iyl

	cp ixh
	cp ixl
	cp iyh
	cp iyl

	sll a
	sll b
	sll c
	sll d
	sll e
	sll h
	sll l
	sll (hl)

	sll (ix+20h)
	sll (iy+20h)

	end
