
	.gba

	.include ver

	.open INPUT_FILE, OUTPUT_FILE, 0x8000000
	.org HIVE_TRACK_DAMAGE_ADDR

	mov r0, 0x80 // final damage struct offset
	add r0, r0, r4
	ldrh r2, [r0,0x2] // read panel damage 1
	ldrh r1, [r0,0x6] // read panel damage 3
	orr r2, r1
	ldr r1, [r0,0x8] // read panel damage 4 and 5 at the same time
	orr r2, r1
	ldrh r1, [r0,0xc] // read panel damage 6 (poison)
	orr r2, r1

	.org HIVE_CLEAR_DAMAGE_ADDR
	
	mov r1, 0x8c // panel damage 6 + some other field that needs to be cleared
	str r0, [r4,r1] // clear both

	.org HIVE_TOTAL_HITS_ADDR
	mov r0, 36

	.org HIVE_SKIP_DAMAGE_SPAWN_BEES_CHECK_ADDR
	// check hive state
	// ldrb r0, [r7,#oAIAttackVars_Unk_01]
	// have we set hive hit vars?
	// cmp r0, #1
	beq @@hiveHitVarsInitialized
	nop

	// reset var that checks if the hive was attacked
	mov r0, #0
	str r0, [r7,0x30]

	// read from hive hits counter
	ldrh r0, [r7,0x12]
	// decrement
	sub r0, #1
	// do not check hive hits if we've reached the maximum number of hits
	blt @@skipHiveHitCheck
	// write new hive hit value
	strh r0, [r7,0x12]

	// indicate that we've set hive vars
	mov r0, #1
	strb r0, [r7,0x1]
	// set hive timer
	mov r0, #30
	strh r0, [r7,0x10]

@@hiveHitVarsInitialized:
	ldr r0, [r7, 0x30]
	cmp r0, #0
	beq @@skipHiveHitCheck
	bl hive_spawnBeeSwarm
	// set var to reset hive vars
	mov r0, #0
	strb r0, [r7, 0x1]
@@skipHiveHitCheck:
	ldrh r0, [r7, 0x10]
	sub r0, #1
	strh r0, [r7, 0x10]
	bge hive_doneAttackIteration

	.close
