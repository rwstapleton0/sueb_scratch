
/// Unsure of best way to approach this...
/// I want to be able to create 'Base<T>' this is either can be of type 'Item' or 'Char'
/// there should be a selection of abilitys all base around the energy, power, rush combo
/// 
/// If the type is a 'Char it should just have base stats. Whereas if its an item, I want
/// to be able to give it special effects, we can get really fun with it.
/// 
/// This should be a store of the items possible. Will use a shared object and then, df to
/// hold 'ItemType's against a string name, protected by an 'AdminCap'
/// 
/// 
/// The bit im struggling with is how to store stats + special effects??
/// probably just give the item type base stats.
/// 
/// requirments: be able to hold x many effects

/// solutions:
/// vectors -
///     pros: 
///     cons: 'Char' will also have an effects field.
/// df -
///     pros: 
///     cons: need 

 
/// Think this might be one of those times where im over enegining the problem.
/// Just a vector will do. + 'Char's should probably have the effects of the items
/// they are made from.
/// 
module complex_nested_df::basic_structs {
    struct BaseStats has store, copy {
        energy: u64,
        power: u64,
        rush: u64,
    }

    struct UniqueEffects has store, copy {}

    public fun create_base_stats(energy: u64, power: u64, rush: u64): BaseStats {
        BaseStats { energy, power, rush }
    }
}

module complex_nested_df::complex_nested_df {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    use std::string::{Self, String};
    use std::vector;
    use std::option::{Self, Option};

    use complex_nested_df::complex_nested_df_minter::{Base};
    use complex_nested_df::basic_structs::{Self, BaseStats, UniqueEffects};

    struct ItemStore has key { id: UID }

    struct ItemType has store, copy {
        name: String,
        type: String,
        base: Option<BaseStats>, // maybe option, not everything has base stats...
        effects: vector<UniqueEffects>
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(ItemStore {id: object::new(ctx)});
    }

    public fun new_item_type(self: &mut ItemStore) {
        let base = option::some(basic_structs::create_base_stats(4, 7, 1));
        let effects = vector::empty<UniqueEffects>();
        
        let item = ItemType { 
            name: string::utf8(b"cool_orb"), 
            type: string::utf8(b"orb"), 
            base, 
            effects,
        };

        dynamic_field::add(&mut self.id, b"cool_orb", item);
    }

    public fun create_item_type(self: &mut ItemStore, name: vector<u8>): ItemType {
        let item = dynamic_field::borrow<vector<u8>, ItemType>(&mut self.id, name);
        ItemType {
            name: item.name,
            type: item.type,
            base: item.base,
            effects: item.effects
        }
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}

module complex_nested_df::complex_nested_df_minter {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use std::string::String;
    use std::vector;

    use complex_nested_df::complex_nested_df::{Self, ItemStore, ItemType};

    struct Item has drop {}

    struct Base<phantom T> has key {
        id: UID,
        level: u64,
        item: ItemType
    }

    public fun create_base<T>(item: ItemType, ctx: &mut TxContext): Base<T> {
        Base<T> { 
            id: object::new(ctx), 
            level: 1,
            item
        }
    }

    public fun mint<T>(store: &mut ItemStore, ctx: &mut TxContext) {
        let base = complex_nested_df::create_item_type(store, b"cool_orb");

        transfer::transfer(create_base<T>(base, ctx), tx_context::sender(ctx) );
    }

    #[test_only] use sui::test_scenario as ts;

    #[test_only] const ADMIN: address = @0xAD;

    #[test]
    public fun test_mint() {
        let ts = ts::begin(@0x0);
        let store: ItemStore;
        {
            ts::next_tx(&mut ts, ADMIN);
            complex_nested_df::test_init(ts::ctx(&mut ts));
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            store = ts::take_shared(&mut ts);
            complex_nested_df::new_item_type(&mut store);
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            mint<Item>(&mut store, ts::ctx(&mut ts));
        };

        ts::return_shared(store);
        ts::end(ts);
    }
}

