
// I want to be able to lock something in kiosk, and ideally
// mutate it from a transaction triggers by someone else.
// this way I dont have to move the object to the game.

// yeah this was obvs not going to work, cant even look up an object
// with ownership, suppose my theory was its a share object soo something XD?

module lockable_kiosk::lockable_kiosk {

    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    use std::option::{Self, Option};
    use sui::package::{Self, Publisher};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};
    use sui::coin::{Self, Coin};
    use sui::transfer_policy::{Self as policy, TransferPolicy, TransferPolicyCap};
    use sui::item_locked_policy as locked_policy;

    struct MyItem has key, store {
        id: UID,
        gene: u64,
    }
    
    struct OTW has drop {}

    public fun change_gene(self: &mut MyItem) {
        self.gene = 67
    }

    public fun create_item(ctx: &mut TxContext): MyItem {
        MyItem {
            id: object::new(ctx),
            gene: 62
        }
    }

    #[test_only] const ADMIN: address = @0xAD;
    #[test_only] use sui::test_scenario as ts;
    #[test_only] use sui::kiosk_test_utils as kiosk_ts;

    #[test]
    public fun test_mutate_outside() {
        let ts = ts::begin(@0x0);
        let (kiosk, cap);
        let (policy, policy_cap);
        let itemId;
        {
            ts::next_tx(&mut ts, ADMIN);
            (kiosk, cap) = kiosk_ts::get_kiosk(ts::ctx(&mut ts));
            (policy, policy_cap) = get_policy(ts::ctx(&mut ts));
            locked_policy::set(&mut policy, &policy_cap);
        
            // Create an item and get its id.
            let item = create_item(ts::ctx(&mut ts));
            itemId = object::id(&item);

            assert!(item.gene == 62, 0);

            // Lock my new item in the kiosk
            kiosk::lock<MyItem>(&mut kiosk, &cap, &policy, item);

        };
        {
            ts::next_tx(&mut ts, ADMIN);

            let item = kiosk::borrow_mut<MyItem>(&mut kiosk, &cap, itemId);

            item.gene = 64;

            assert!(item.gene == 64, 0);

        };

        // Return policy stuff
        return_policy(policy, policy_cap, ts::ctx(&mut ts));
        
        // kiosk has stuff in it so cant return, send to bob instead, carl's on well deserved holiday.
        transfer::public_transfer(kiosk, @0xB0B);
        transfer::public_transfer(cap, @0xB0B);
        // kiosk_ts::return_kiosk(kiosk, cap, ts::ctx(&mut ts));
        ts::end(ts);
    }

    #[test]
    public fun test_create() {
        let ts = ts::begin(@0x0);
        let (kiosk, cap);
        let (policy, policy_cap);
        let itemId;
        {
            ts::next_tx(&mut ts, ADMIN);
            (kiosk, cap) = kiosk_ts::get_kiosk(ts::ctx(&mut ts));
            (policy, policy_cap) = get_policy(ts::ctx(&mut ts));

            // Set lock policy
            locked_policy::set(&mut policy, &policy_cap);
        
            // Create an item and get its id.
            let item = create_item(ts::ctx(&mut ts));
            itemId = object::id(&item);

            assert!(item.gene == 62, 0);

            // Lock my new item in the kiosk
            kiosk::lock<MyItem>(&mut kiosk, &cap, &policy, item);

        };
            // I want to try borrow_mut which is fine? ideally trigger by someone
            // else which isn't possible i dont think as you need kiosk cap.
            // so is there a way around this without having to write a new system,
            // No, I dont think so... 

            // unless you stop that sueb from being registared into a new game,
            // if its address is already in a game somewhere.
            // This case they will have to go close that game take the penialty for a lose.
            
            // However, I may be able to add a transfer policy that records when,
            // someone entrys a game so then I dont have to gum up some vector managed,
            // by the game?
        {
            ts::next_tx(&mut ts, ADMIN);

            let item = kiosk::borrow_mut<MyItem>(&mut kiosk, &cap, itemId);

            item.gene = 64;

            assert!(item.gene == 64, 0);

        };

        // Return policy stuff
        return_policy(policy, policy_cap, ts::ctx(&mut ts));
        
        // kiosk has stuff in it so cant return, send to bob instead, carl's on well deserved holiday.
        transfer::public_transfer(kiosk, @0xB0B);
        transfer::public_transfer(cap, @0xB0B);
        // kiosk_ts::return_kiosk(kiosk, cap, ts::ctx(&mut ts));
        ts::end(ts);
    }

    /// Get the Publisher object.
    public fun get_publisher(ctx: &mut TxContext): Publisher {
        package::test_claim(OTW {}, ctx)
    }

    /// Prepare: TransferPolicy<Asset>
    public fun get_policy(ctx: &mut TxContext): (TransferPolicy<MyItem>, TransferPolicyCap<MyItem>) {
        let publisher = get_publisher(ctx);
        let (policy, cap) = policy::new(&publisher, ctx);
        kiosk_ts::return_publisher(publisher);
        (policy, cap)
    }

    /// Cleanup: TransferPolicy
    public fun return_policy(policy: TransferPolicy<MyItem>, cap: TransferPolicyCap<MyItem>, ctx: &mut TxContext): u64 {
        let profits = policy::destroy_and_withdraw(policy, cap, ctx);
        coin::burn_for_testing(profits)
    }
}
