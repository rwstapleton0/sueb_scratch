module kiosk_to_shared::kiosk_to_shared {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID, ID};
    use sui::transfer;

    use std::option::{Self, Option};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};

    struct MyItem has key, store {
        id: UID,
        gene: u64,
    }

    struct SharedSafe<T: store + key> has key, store {
        id: UID,
        store: Option<T>,
    }

    public fun create_safe<T: store + key>(ctx: &mut TxContext) {
        transfer::share_object(SharedSafe<T>{
            id: object::new(ctx),
            store: option::none(),
        });
    }

    public fun move_kiosk_to_safe<T: store + key>(
        kiosk: &mut Kiosk,
        cap: &KioskOwnerCap,
        itemId: ID,
        safe: &mut SharedSafe<T>
    ) {
        let item = kiosk::take<T>(kiosk, cap, itemId);

        option::fill(&mut safe.store, item);
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
    public fun test_create() {
        let ts = ts::begin(@0x0);
        let safe: SharedSafe<MyItem>;
        let kiosk: Kiosk;
        let cap: KioskOwnerCap;
        let itemId: ID;
        {
            ts::next_tx(&mut ts, ADMIN);
            create_safe<MyItem>(ts::ctx(&mut ts));
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            safe = ts::take_shared(&mut ts);

            let item = create_item(ts::ctx(&mut ts));
            itemId = object::id(&item);

            (kiosk, cap) = kiosk_ts::get_kiosk(ts::ctx(&mut ts));

            kiosk::place(&mut kiosk, &cap, item);

            let item = kiosk::borrow<MyItem>(&mut kiosk, &cap, itemId);
            assert!(item.gene == 62, 1);
        };
        {
            ts::next_tx(&mut ts, ADMIN);

            move_kiosk_to_safe<MyItem>(&mut kiosk, &cap, itemId, &mut safe);
        };
        kiosk_ts::return_kiosk(kiosk, cap, ts::ctx(&mut ts));
        ts::return_shared(safe);
        ts::end(ts);
    }
}