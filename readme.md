# Anime Ninja Simulator

Anime Ninja Simulator is a multiplayer Naruto IP based MMORPG game. Anime Ninja Simulator should have well maintained support for Desktop and Mobile.

### Dependencies

The project utilizes various helper modules to increase code development efficiency and also attempts to minimize potential bug caused by faulty code.

> **Knit**\
> Knit orientates core game logic around services and controllers, allowing us to inherit cleaner organization across codebases and easier maintainability.\
> [Documentation](https://sleitnick.github.io/Knit/docs/intro)

> **Janitor**\
> Light-weight, flexible object for cleaning up connections, instances, or anything. This implementation covers all use cases, as it doesn't force you to rely on naive typechecking to guess how an instance should be cleaned up. Instead, the developer may specify any behavior for any object.\
> [Documentation](https://rostrap.github.io/Libraries/Events/Janitor/)

> **ProfileService**\
> ProfileService is a stand-alone ModuleScript that specialises in loading and auto-saving DataStore profiles. ProfileService does not give you any data getter or setter functions. It gives you the freedom to write your own data interface. Low resource footprint, no excessive type checking. It is great for 100+ player servers. ProfileService automatically spreads the DataStore API calls evenly within the auto-save loop timeframe.\
> [Documentation](https://madstudioroblox.github.io/ProfileService/)

> **Promise**\
> Promises model asynchronous operations in a way that makes them delightful to work with. The library includes many utility functions beyond the basic functionality. Promises support cancellation, which allows you to prematurely stop an async task.\
> [Documentation](https://eryn.io/roblox-lua-promise/api/Promise)

> **t**\
> t is a module which allows you to create type definitions to check values against. When building large systems, it can often be difficult to find type mismatch bugs. Typechecking helps you ensure that your functions are recieving the appropriate types for their arguments.\
> [Documentation](https://github.com/osyrisrblx/t)

> **BoatTween**\
> BoatTween offers 32 easing styles (compared to Roblox’s 11) and they all have the 3 easing directions as well, allowing you to find exactly the tween timing you desire. It covers serveral TweenService insufficiency and brings more API to the table. `The util module already forks a fast tween method using BoatTween` \
> [Documentation](https://github.com/boatbomber/BoatTween)

### Code Guidelines


This project prioritize `OOP` over `POP`. 