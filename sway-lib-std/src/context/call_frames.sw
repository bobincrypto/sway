//! Helper functions for accessing data from call frames.
/// Call frames store metadata across untrusted inter-contract calls:
/// https://github.com/FuelLabs/fuel-specs/blob/master/specs/vm/main.md#call-frames
library call_frames;

use ::contract_id::ContractId;

// Note that everything when serialized is padded to word length.
//
// Call Frame        :  saved registers = 8*WORD_SIZE = 8*8 = 64
// Reserved Registers:  frame pointer   = 6*WORD_SIZE = 6*8 = 48

const SAVED_REGISTERS_OFFSET = 64;
const CALL_FRAME_OFFSET = 48;

///////////////////////////////////////////////////////////
//  Accessing the current call frame
///////////////////////////////////////////////////////////

/// Get the current contract's id when called in an internal context.
/// **Note !** If called in an external context, this will **not** return a contract ID.
// @dev If called externally, will actually return a pointer to the transaction ID.
pub fn contract_id() -> ContractId {
    ~ContractId::from(asm() {
        fp: b256
    })
}

/// Get the asset_id of coins being sent from the current call frame.
pub fn msg_asset_id() -> ContractId {
    ~ContractId::from(asm(asset_id) {
        addi asset_id fp i32;
        asset_id: b256
    })
}

/// Get the code size in bytes (padded to word alignment) from the current call frame.
pub fn code_size() -> u64 {
    asm(size, ptr, offset: 576) {
        add size fp offset;
        size: u64
    }
}

/// Get the first parameter from the current call frame.
pub fn first_param() -> u64 {
    asm(size, ptr, offset: 584) {
        add size fp offset;
        size: u64
    }
}

/// Get the second parameter from the current call frame.
pub fn second_param() -> u64 {
    asm(size, ptr, offset: 592) {
        add size fp offset;
        size: u64
    }
}

///////////////////////////////////////////////////////////
//  Accessing arbitrary call frames by pointer
///////////////////////////////////////////////////////////

/// get a pointer to the previous (relative to the 'frame_pointer' param) call frame using offsets from a pointer.
pub fn get_previous_frame_pointer(frame_pointer: u64) -> u64 {
    // let offset = SAVED_REGISTERS_OFFSET + CALL_FRAME_OFFSET;
    let offset = 64 + 48;
    asm(res, ptr: frame_pointer, offset: offset) {
        add res ptr offset;
        res: u64
    }
}

/// get the value of the previous `ContractId` from the previous call frame on the stack.
pub fn get_previous_contract_id(previous_frame_ptr: u64) -> ContractId {
    ~ContractId::from(asm(res, ptr: previous_frame_ptr) {
        ptr: b256
    })
}