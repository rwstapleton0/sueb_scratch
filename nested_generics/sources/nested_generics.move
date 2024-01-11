module nested_generics::nested_generics {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;
    // Cap
    struct AppCap has store, drop { app_name: u64 }

    // Apps
    struct QuestApp has key { id: UID }

    // Keys
    struct LevelKey has copy, store, drop {}
 
    struct MintKey has copy, store, drop {}

    public fun authorize_app<T: copy + store + drop>(
        app: &mut UID,
        key: T,
        app_name: u64
    ) {
        dynamic_field::add(app, key, AppCap { app_name })
    }

    #[test_only] use sui::test_scenario as ts;
    #[test_only] const ADMIN: address = @0xAD;

    #[test]
    public fun test_give_key() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            let quests = QuestApp { id: object::new(ts::ctx(&mut ts)) };

            authorize_app<MintKey>(&mut quests.id, MintKey {}, 1 );
            transfer::transfer(quests, ADMIN);
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            let quests = QuestApp { id: object::new(ts::ctx(&mut ts)) };

            authorize_app<LevelKey>(&mut quests.id, LevelKey {}, 1 );
            transfer::transfer(quests, ADMIN);
        };
        ts::end(ts);
    }
}

module nested_generics::nested_generics2 {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;
    // Cap
    struct AppCap has store, drop { app_name: u64 }

    // Type - key<type>
    struct SuebType has drop {}

    // Apps
    struct QuestApp has key { id: UID }

    // Keys
    struct MintKey<phantom T> has copy, store, drop {}

    public fun authorize_app<T: copy + store + drop>(
        app: &mut UID,
        key: T,
        app_name: u64
    ) {
        dynamic_field::add(app, key, AppCap { app_name })
    }

    #[test_only] use sui::test_scenario as ts;
    #[test_only] const ADMIN: address = @0xAD;

    #[test]
    public fun test_give_key() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            let quests = QuestApp { id: object::new(ts::ctx(&mut ts)) };

            // that was simple XD
            authorize_app<MintKey<SuebType>>(&mut quests.id, MintKey<SuebType> {}, 1 );
            transfer::transfer(quests, ADMIN);
        };
        
        ts::end(ts);
    }
}

module nested_generics::nested_generics3 {
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    // Cap
    struct AppCap has store, drop {
        app_name: u64
    }

    // Apps
    struct GameApp has key { id: UID }

    struct QuestApp has key { id: UID }

    // Types
    struct SuebType has drop {}

    struct RelicType has drop {}


    // Cap keys
    struct MintKey<phantom T> has copy, store, drop {}

    struct LevelKey<phantom T> has copy, store, drop {}

    // Auth Funs
    public fun is_authorized<T: copy + store + drop>(app: &UID, key: T): bool {
        dynamic_field::exists_(app, key)
    }

    public fun authorize_app<T: copy + store + drop>(
        app: &mut UID,
        key: T,
        app_name: u64
    ) {
        dynamic_field::add(app, key, AppCap { app_name })
    }

    #[test_only] use sui::test_scenario::{Self as ts, Scenario};
    #[test_only] const ADMIN: address = @0xAD;

    #[test]
    public fun test_create_app_give_key() {
        let ts = ts::begin(@0x0);
        let quest: QuestApp;
        {
            ts::next_tx(&mut ts, ADMIN);
            quest = QuestApp { id: object::new(ts::ctx(&mut ts)) };
            authorize_app<MintKey<SuebType>>(&mut quest.id, MintKey<SuebType> {}, 1 );
            assert!(is_authorized(&quest.id, MintKey<SuebType> {}), 0)
        };
        transfer::transfer(quest, ADMIN);
        ts::end(ts);
    }

    #[test]
    #[expected_failure(abort_code = 0)]
    public fun test_create_app_dont_give_key() {
        let ts = ts::begin(@0x0);
        let quest: QuestApp;
        {
            ts::next_tx(&mut ts, ADMIN);
            quest = QuestApp { id: object::new(ts::ctx(&mut ts)) };
            // authorize_app<MintKey<SuebType>>(&mut quest.id, MintKey<SuebType> {}, 1 );
            assert!(is_authorized(&quest.id, MintKey<SuebType> {}), 0)
        };
        transfer::transfer(quest, ADMIN);
        ts::end(ts);
    }


    #[test]
    #[expected_failure(abort_code = 0)]
    public fun test_create_app_give_wrong_key() {
        let ts = ts::begin(@0x0);
        let quest: QuestApp;
        {
            ts::next_tx(&mut ts, ADMIN);
            quest = QuestApp { id: object::new(ts::ctx(&mut ts)) };
            authorize_app<LevelKey<SuebType>>(&mut quest.id, LevelKey<SuebType> {}, 1 );
            assert!(is_authorized(&quest.id, MintKey<SuebType> {}), 0)
        };
        transfer::transfer(quest, ADMIN);
        ts::end(ts);
    }


    #[test]
    #[expected_failure(abort_code = 0)]
    public fun test_create_app_give_key_wrong_type() {
        let ts = ts::begin(@0x0);
        let quest: QuestApp;
        {
            ts::next_tx(&mut ts, ADMIN);
            quest = QuestApp { id: object::new(ts::ctx(&mut ts)) };
            authorize_app<MintKey<RelicType>>(&mut quest.id, MintKey<RelicType> {}, 1 );
            assert!(is_authorized(&quest.id, MintKey<SuebType> {}), 0)
        };
        transfer::transfer(quest, ADMIN);
        ts::end(ts);
    }
}