module generic_101::generic_101 {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    use std::option::{Self, Option};
    use sui::kiosk::{Self, Kiosk, KioskOwnerCap};

    struct MyItem has store, drop {
        gene: u64,
    }

    fun init<T: drop>(ctx: &mut TxContext) {
        let box = Box<T> {
            value: option::none()
        };

    }

    public fun create_item(): MyItem {
        MyItem {
            gene: 5
        }
    }

    struct Box<T: drop> has store, drop {
        value: Option<T>
    }

    public fun create_box<T: drop>(val: T): Box<T> {
        Box<T> {
            value: option::some(val)
        }
    }

    public fun create_empty_box<T: drop>(): Box<T> {
        Box<T> {
            value: option::none()
        }
    }

    public fun fill_box<T: drop>(box: &mut Box<T>, item: T): &mut Box<T> {
        option::fill(&mut box.value, item);
        box
    }

    #[test_only] const ADMIN: address = @0xAD;
    #[test_only] use sui::test_scenario as ts;
    #[test]
    public fun test_create_box<T: drop>() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            init<T>(ts::ctx(&mut ts));
            let numBox = create_box<u64>(4);

            let item = create_item();
            let itemBox = create_box<MyItem>(item);

            let item2 = create_item();
            let emptyBox = create_empty_box();
            let filledBox = fill_box<MyItem>(&mut emptyBox, item2);
        };
        ts::end(ts);
    }
}