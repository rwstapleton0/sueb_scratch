
// My idea is to use a transfer policy to block any action on a sueb, if that sueb
// has an game that needs resolving, to stop people from removing their sueb without
// taking damage.

// Am i over engineering this??? Could i just link the game id on the sueb? 

// may need both?? policy would stop someone trading a sueb with a locked game.
// but just an ID pointer on the sueb would stop someone from entering a new game?

module custom_policy_kiosk::custom_policy_kiosk {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::transfer;

    use std::option::{Self, Option};
    use sui::package::{Self, Publisher};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::coin::{Self, Coin};
    use sui::transfer_policy::{Self as policy, TransferPolicy, TransferPolicyCap};

    struct DaGame {
        id: UID,
        player_one: Option<ID>,
    }

    struct MyPlayer {
        id: UID,
        current_game: Option<ID>,
    }

    #[test_only] const ADMIN: address = @0xAD;
    #[test_only] use sui::test_scenario as ts;
    #[test_only] use sui::kiosk_test_utils as kiosk_ts;
    #[test]
    public fun test_create() {
        let ts = ts::begin(@0x0);
        let (kiosk, cap);
        let (policy, policy_cap);
        let itemId;
        {
            ts::next_tx(&mut ts, ADMIN);
            (kiosk, cap) = kiosk_ts::get_kiosk(ts::ctx(&mut ts));
            (policy, policy_cap) = kiosk_ts::get_policy(ts::ctx(&mut ts));
        };


        // Return policy stuff
        kiosk_ts::return_policy(policy, policy_cap, ts::ctx(&mut ts));
        // kiosk has stuff in it so cant return, send to bob instead, carl's on well deserved holiday.
        // transfer::public_transfer(kiosk, @0xB0B);
        // transfer::public_transfer(cap, @0xB0B);
        kiosk_ts::return_kiosk(kiosk, cap, ts::ctx(&mut ts));
        ts::end(ts);
    }
}