// This is a simplified version of the Suifrens example.

// I want to try make 2 sui apps. 
// 1 where both types can use
// 1 where only BodType can use.

// ideally id like to have stats on 1, but dont this makes sense here.
// because... well...

// diverting for the suifrens example by not using dynamic fields for app caps.
// will try 

// in the example this is the key function, checks if the UID for the app is stored in a key._
// which means it has an AppCap. <- something like this?? XD

    /// Check whether an Application has a permission to mint or
    /// burn a specific SuiFren<T>.
    // public fun is_authorized<T>(app: &UID): bool {
    //     df::exists_<AppKey<T>>(app, AppKey {})
    // }

// this stops the entry points of authorized apps from having to pass in AppCap.
// this doesnt matter to me rn so just returning the AppCap, will test this later.

// The AppCap does need to be attached to the new app somehow... otherwise any app could 
// use it.  we need someway of attaching app_cap to the object without needing to copy 
// option does the job here as option give us a borrow.

module app_authorizer::floobod_builder {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use app_authorizer::app_authorizer::{Self, Floobod, AppCap, AdminCap};
    use sui::transfer;
    use std::option::{Self, Option};

    struct FloobodBuilder has key, store {
        id: UID,
        app_cap: Option<AppCap>,
    }

    struct Bod has drop {}

    struct Floob has drop {}

    fun init(ctx: &mut TxContext) {
        transfer::transfer(FloobodBuilder {
            id: object::new(ctx),
            app_cap: option::none(),
        }, tx_context::sender(ctx));
    }

    public fun mint<T>(app: &FloobodBuilder, ctx: &mut TxContext): Floobod<T> {
        let app_cap = option::borrow(&app.app_cap);
        app_authorizer::mint<T>(app_cap, ctx)
    }

    // I dont think this way we can differ between <T>??
    public fun authorizer_me<T>(admin_cap: &AdminCap, app: &mut FloobodBuilder, ctx: &mut TxContext) {
        let cap = app_authorizer::authorizer_app<T>(admin_cap, ctx);
        option::fill(&mut app.app_cap, cap);
    }

    #[test_only] use sui::test_scenario as ts;
    #[test_only] const ADMIN: address = @0xAD;

    #[test]
    public fun test_mint() {
        let ts = ts::begin(@0x0);
        let app: FloobodBuilder;
        let admin_cap: AdminCap;
        {
            ts::next_tx(&mut ts, ADMIN);
            init(ts::ctx(&mut ts));
            app_authorizer::test_init(ts::ctx(&mut ts));
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            app = ts::take_from_sender(&mut ts);
            admin_cap = ts::take_from_sender(&mut ts);

            authorizer_me<Bod>(&admin_cap, &mut app, ts::ctx(&mut ts));
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            let bod = mint<Bod>(&app, ts::ctx(&mut ts));
            transfer::public_transfer(bod, ADMIN);
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            let bod = mint<Floob>(&app, ts::ctx(&mut ts));
            transfer::public_transfer(bod, ADMIN);
        };
        ts::return_to_sender(&mut ts, app);
        ts::return_to_sender(&mut ts, admin_cap);
        ts::end(ts);
    }
}

module app_authorizer::app_authorizer {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    struct Floobod<phantom T> has key, store {
        id: UID,
        level: u64
    }

    // AdminCap is for me, its then used to allow other apps to mint.
    struct AdminCap has key, store { id: UID }

    struct AppCap has key, store { id: UID }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap{ id: object::new(ctx) },
            tx_context::sender(ctx)
        );
    }

    // app is the authorizer check here. &mut UID... for some reason.
    public fun mint<T>(app_cap: &AppCap, ctx: &mut TxContext): Floobod<T> {
        Floobod {
            id: object::new(ctx),
            level: 0,
        }
    }

    // example passes T I assume this is due to having to authorizer each type? will test.
    public fun authorizer_app<T>(_: &AdminCap, ctx: &mut TxContext): AppCap {
        AppCap {
            id: object::new(ctx)
        }
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }


}