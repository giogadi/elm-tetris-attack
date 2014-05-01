Elm.TetrisAttack = Elm.TetrisAttack || {};
Elm.TetrisAttack.make = function (_elm) {
   "use strict";
   _elm.TetrisAttack = _elm.TetrisAttack || {};
   if (_elm.TetrisAttack.values)
   return _elm.TetrisAttack.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "TetrisAttack";
   var Basics = Elm.Basics.make(_elm);
   var Board = Elm.Board.make(_elm);
   var Color = Elm.Color.make(_elm);
   var DrawBoard = Elm.DrawBoard.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var PortableBoard = Elm.PortableBoard.make(_elm);
   var Pseudorandom = Elm.Pseudorandom.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var UpdateBoard = Elm.UpdateBoard.make(_elm);
   var WebSocket = Elm.WebSocket.make(_elm);
   var Window = Elm.Window.make(_elm);
   var _op = {};
   var mkInitialBoard = Board.boardFromRandomInts(Basics.fst(A2(Pseudorandom.randomRange,
   {ctor: "_Tuple2",_0: 0,_1: 3},
   Board.boardRows * Board.boardColumns)(1)));
   var mkInitialState = {_: {}
                        ,board: mkInitialBoard
                        ,cursorIdx: {ctor: "_Tuple2"
                                    ,_0: 0
                                    ,_1: 0}
                        ,dtOld: 0};
   var stateSignal = A3(Signal.foldp,
   UpdateBoard.stepGame,
   mkInitialState,
   UpdateBoard.input);
   var outSignal = Signal.lift(PortableBoard.stateToString)(stateSignal);
   var stateAndInSignal = A2(Signal.lift2,
   F2(function (v0,v1) {
      return {ctor: "_Tuple2"
             ,_0: v0
             ,_1: v1};
   }),
   stateSignal)(A2(WebSocket.connect,
   "ws://0.0.0.0:9160",
   outSignal));
   var main = A2(Signal.lift2,
   DrawBoard.displayGame,
   Window.dimensions)(A2(Signal.lift,
   Basics.fst,
   stateAndInSignal));
   _elm.TetrisAttack.values = {_op: _op
                              ,mkInitialBoard: mkInitialBoard
                              ,mkInitialState: mkInitialState
                              ,stateSignal: stateSignal
                              ,outSignal: outSignal
                              ,stateAndInSignal: stateAndInSignal
                              ,main: main};
   return _elm.TetrisAttack.values;
};Elm.UpdateBoard = Elm.UpdateBoard || {};
Elm.UpdateBoard.make = function (_elm) {
   "use strict";
   _elm.UpdateBoard = _elm.UpdateBoard || {};
   if (_elm.UpdateBoard.values)
   return _elm.UpdateBoard.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "UpdateBoard";
   var Basics = Elm.Basics.make(_elm);
   var Board = Elm.Board.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var Keyboard = Elm.Keyboard.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var NewTimeStep = function (a) {
      return {ctor: "NewTimeStep"
             ,_0: a};
   };
   var Swap = {ctor: "Swap"};
   var CursorUp = {ctor: "CursorUp"};
   var CursorDown = {ctor: "CursorDown"};
   var CursorRight = {ctor: "CursorRight"};
   var CursorLeft = {ctor: "CursorLeft"};
   var None = {ctor: "None"};
   var onDown = function ($) {
      return Signal.lift(function (_v0) {
         return function () {
            return {ctor: "_Tuple0"};
         }();
      })(A2(Signal.keepIf,
      Basics.not,
      false)(Signal.dropRepeats($)));
   };
   var onReleased = function ($) {
      return onDown(Keyboard.isDown($));
   };
   var onUp = function ($) {
      return Signal.lift(function (_v2) {
         return function () {
            return {ctor: "_Tuple0"};
         }();
      })(A2(Signal.keepIf,
      Basics.id,
      false)(Signal.dropRepeats($)));
   };
   var onPressed = function ($) {
      return onUp(Keyboard.isDown($));
   };
   var keyPressed = F2(function (key,
   action) {
      return Signal.merge(Signal.constant(None))(A2(Signal._op["<~"],
      Basics.always(action),
      onPressed(key)));
   });
   var input = function () {
      var keyPressInput = Signal.merges(A3(List.zipWith,
      keyPressed,
      _L.fromArray([37,39,40,38,32]),
      _L.fromArray([CursorLeft
                   ,CursorRight
                   ,CursorDown
                   ,CursorUp
                   ,Swap])));
      return Signal.merge(keyPressInput)(A2(Signal._op["<~"],
      NewTimeStep,
      Time.fps(60)));
   }();
   var combineMatches = function () {
      var tileOr = F2(function (t1,
      t2) {
         return function () {
            var _v4 = {ctor: "_Tuple2"
                      ,_0: t1
                      ,_1: t2};
            switch (_v4.ctor)
            {case "_Tuple2":
               switch (_v4._0.ctor)
                 {case "Just":
                    switch (_v4._0._0.ctor)
                      {case "_Tuple2":
                         switch (_v4._0._0._1.ctor)
                           {case "Matching":
                              switch (_v4._1.ctor)
                                {case "Just":
                                   switch (_v4._1._0.ctor)
                                     {case "_Tuple2":
                                        return Maybe.Just({ctor: "_Tuple2"
                                                          ,_0: _v4._0._0._0
                                                          ,_1: Board.Matching(_v4._0._0._1._0)});}
                                     break;}
                                break;}
                           switch (_v4._1.ctor)
                           {case "Just":
                              switch (_v4._1._0.ctor)
                                {case "_Tuple2":
                                   switch (_v4._1._0._1.ctor)
                                     {case "Matching":
                                        return Maybe.Just({ctor: "_Tuple2"
                                                          ,_0: _v4._0._0._0
                                                          ,_1: Board.Matching(_v4._1._0._1._0)});}
                                     break;}
                                break;}
                           break;}
                      break;}
                 return _v4._0;}
            _E.Case($moduleName,
            "between lines 142 and 147");
         }();
      });
      return List.zipWith(List.zipWith(tileOr));
   }();
   var updateMatchesInList = function (tileList) {
      return function () {
         var match = F2(function (stack,
         numMatches) {
            return function () {
               switch (numMatches)
               {case 0: return stack;}
               return function () {
                  var _v19 = List.head(stack);
                  switch (_v19.ctor)
                  {case "Just":
                     switch (_v19._0.ctor)
                       {case "_Tuple2":
                          return {ctor: "::"
                                 ,_0: Maybe.Just({ctor: "_Tuple2"
                                                 ,_0: _v19._0._0
                                                 ,_1: Board.Matching(0.0)})
                                 ,_1: A2(match,
                                 List.tail(stack),
                                 numMatches - 1)};}
                       break;}
                  _E.Case($moduleName,
                  "between lines 121 and 124");
               }();
            }();
         });
         var tryMatch = F2(function (stack,
         numMatches) {
            return _U.cmp(numMatches,
            3) > -1 ? A2(match,
            stack,
            numMatches) : stack;
         });
         var go = F3(function (newList,
         numInARow,
         ts) {
            return function () {
               switch (ts.ctor)
               {case "::": switch (ts._0.ctor)
                    {case "Just":
                       switch (ts._0._0.ctor)
                         {case "_Tuple2":
                            switch (ts._0._0._1.ctor)
                              {case "Stationary":
                                 return function () {
                                      switch (newList.ctor)
                                      {case "::":
                                         switch (newList._0.ctor)
                                           {case "Just":
                                              switch (newList._0._0.ctor)
                                                {case "_Tuple2":
                                                   switch (newList._0._0._1.ctor)
                                                     {case "Stationary":
                                                        return _U.eq(ts._0._0._0,
                                                          newList._0._0._0) ? A3(go,
                                                          {ctor: "::"
                                                          ,_0: List.head(ts)
                                                          ,_1: newList},
                                                          numInARow + 1,
                                                          ts._1) : A3(go,
                                                          {ctor: "::"
                                                          ,_0: List.head(ts)
                                                          ,_1: A2(tryMatch,
                                                          newList,
                                                          numInARow)},
                                                          1,
                                                          ts._1);}
                                                     break;}
                                                break;}
                                           break;
                                         case "[]": return A3(go,
                                           _L.fromArray([Maybe.Just({ctor: "_Tuple2"
                                                                    ,_0: ts._0._0._0
                                                                    ,_1: Board.Stationary})]),
                                           1,
                                           ts._1);}
                                      return A3(go,
                                      {ctor: "::"
                                      ,_0: List.head(ts)
                                      ,_1: A2(tryMatch,
                                      newList,
                                      numInARow)},
                                      1,
                                      ts._1);
                                   }();}
                              break;}
                         break;}
                    return A3(go,
                    {ctor: "::"
                    ,_0: ts._0
                    ,_1: A2(tryMatch,
                    newList,
                    numInARow)},
                    0,
                    ts._1);
                  case "[]": return A2(tryMatch,
                    newList,
                    numInARow);}
               _E.Case($moduleName,
               "between lines 128 and 138");
            }();
         });
         return List.reverse(A3(go,
         _L.fromArray([]),
         0,
         tileList));
      }();
   };
   var updateMatches = function (b) {
      return function () {
         var rowMatched = Board.transpose(List.map(updateMatchesInList)(Board.transpose(b)));
         var columnMatched = A2(List.map,
         updateMatchesInList,
         b);
         var allMatched = A2(combineMatches,
         columnMatched,
         rowMatched);
         return allMatched;
      }();
   };
   var updateFallColumn = function (c) {
      return function () {
         var go = F3(function (ts,
         falling,
         proc) {
            return function () {
               switch (ts.ctor)
               {case "::": switch (ts._1.ctor)
                    {case "::":
                       return falling ? function () {
                            switch (ts._0.ctor)
                            {case "Nothing":
                               return function () {
                                    switch (ts._1._0.ctor)
                                    {case "Just":
                                       switch (ts._1._0._0.ctor)
                                         {case "_Tuple2":
                                            switch (ts._1._0._0._1.ctor)
                                              {case "Fell": return A2(go,
                                                   {ctor: "::"
                                                   ,_0: ts._0
                                                   ,_1: ts._1._1},
                                                   true)(_L.append(proc,
                                                   _L.fromArray([Maybe.Just({ctor: "_Tuple2"
                                                                            ,_0: ts._1._0._0._0
                                                                            ,_1: A2(Board.Falling,
                                                                            ts._1._0._0._1._0 - 1.0,
                                                                            ts._1._0._0._1._1)})])));
                                                 case "Stationary":
                                                 return A2(go,
                                                   {ctor: "::"
                                                   ,_0: ts._0
                                                   ,_1: ts._1._1},
                                                   true)(_L.append(proc,
                                                   _L.fromArray([Maybe.Just({ctor: "_Tuple2"
                                                                            ,_0: ts._1._0._0._0
                                                                            ,_1: A2(Board.Falling,
                                                                            0.0,
                                                                            0.0)})])));}
                                              break;}
                                         break;}
                                    return A2(go,
                                    {ctor: "::"
                                    ,_0: ts._0
                                    ,_1: ts._1._1},
                                    true)(_L.append(proc,
                                    _L.fromArray([ts._1._0])));
                                 }();}
                            _E.Case($moduleName,
                            "between lines 94 and 101");
                         }() : function () {
                            switch (ts._0.ctor)
                            {case "Just":
                               switch (ts._0._0.ctor)
                                 {case "_Tuple2":
                                    switch (ts._0._0._1.ctor)
                                      {case "Fell": return A2(go,
                                           {ctor: "::"
                                           ,_0: ts._1._0
                                           ,_1: ts._1._1},
                                           false)(_L.append(proc,
                                           _L.fromArray([Maybe.Just({ctor: "_Tuple2"
                                                                    ,_0: ts._0._0._0
                                                                    ,_1: Board.Stationary})])));}
                                      break;}
                                 break;
                               case "Nothing":
                               return function () {
                                    switch (ts._1._0.ctor)
                                    {case "Just":
                                       switch (ts._1._0._0.ctor)
                                         {case "_Tuple2":
                                            switch (ts._1._0._0._1.ctor)
                                              {case "Fell": return A2(go,
                                                   {ctor: "::"
                                                   ,_0: ts._0
                                                   ,_1: ts._1._1},
                                                   true)(_L.append(proc,
                                                   _L.fromArray([Maybe.Just({ctor: "_Tuple2"
                                                                            ,_0: ts._1._0._0._0
                                                                            ,_1: A2(Board.Falling,
                                                                            ts._1._0._0._1._0 - 1.0,
                                                                            ts._1._0._0._1._1)})])));
                                                 case "Stationary":
                                                 return A2(go,
                                                   {ctor: "::"
                                                   ,_0: ts._0
                                                   ,_1: ts._1._1},
                                                   true)(_L.append(proc,
                                                   _L.fromArray([Maybe.Just({ctor: "_Tuple2"
                                                                            ,_0: ts._1._0._0._0
                                                                            ,_1: A2(Board.Falling,
                                                                            0.0,
                                                                            0.0)})])));}
                                              break;}
                                         break;}
                                    return A2(go,
                                    {ctor: "::"
                                    ,_0: ts._1._0
                                    ,_1: ts._1._1},
                                    false)(_L.append(proc,
                                    _L.fromArray([ts._0])));
                                 }();}
                            return A2(go,
                            {ctor: "::"
                            ,_0: ts._1._0
                            ,_1: ts._1._1},
                            false)(_L.append(proc,
                            _L.fromArray([ts._0])));
                         }();}
                    return _L.append(proc,
                    _L.fromArray([ts._0]));}
               _E.Case($moduleName,
               "between lines 91 and 111");
            }();
         });
         return A3(go,
         c,
         false,
         _L.fromArray([]));
      }();
   };
   var updateFalls = List.map(updateFallColumn);
   var switchTileRight = function (_v59) {
      return function () {
         switch (_v59.ctor)
         {case "_Tuple2":
            return {ctor: "_Tuple2"
                   ,_0: _v59._0
                   ,_1: Board.SwitchingRight(0.0)};}
         _E.Case($moduleName,
         "on line 77, column 27 to 48");
      }();
   };
   var switchTileLeft = function (_v63) {
      return function () {
         switch (_v63.ctor)
         {case "_Tuple2":
            return {ctor: "_Tuple2"
                   ,_0: _v63._0
                   ,_1: Board.SwitchingLeft(0.0)};}
         _E.Case($moduleName,
         "on line 74, column 26 to 46");
      }();
   };
   var switchable = function (t) {
      return function () {
         switch (t.ctor)
         {case "Just": switch (t._0.ctor)
              {case "_Tuple2":
                 switch (t._0._1.ctor)
                   {case "Stationary":
                      return true;}
                   break;}
              break;
            case "Nothing": return true;}
         return false;
      }();
   };
   var swapTiles = F2(function (b,
   _v71) {
      return function () {
         switch (_v71.ctor)
         {case "_Tuple2":
            return function () {
                 var right = A2(Board.getTileAt,
                 b,
                 {ctor: "_Tuple2"
                 ,_0: _v71._0 + 1
                 ,_1: _v71._1});
                 var left = A2(Board.getTileAt,
                 b,
                 {ctor: "_Tuple2"
                 ,_0: _v71._0
                 ,_1: _v71._1});
                 return switchable(left) && switchable(right) ? function () {
                    var b1 = A3(Board.setTileAt,
                    b,
                    {ctor: "_Tuple2"
                    ,_0: _v71._0
                    ,_1: _v71._1},
                    A2(Board.liftMaybe,
                    switchTileLeft,
                    right));
                    return A3(Board.setTileAt,
                    b1,
                    {ctor: "_Tuple2"
                    ,_0: _v71._0 + 1
                    ,_1: _v71._1},
                    A2(Board.liftMaybe,
                    switchTileRight,
                    left));
                 }() : b;
              }();}
         _E.Case($moduleName,
         "between lines 81 and 86");
      }();
   });
   var moveCursorUp = function (_v75) {
      return function () {
         switch (_v75.ctor)
         {case "_Tuple2":
            return _U.eq(_v75._1,
              Board.boardRows - 1) ? {ctor: "_Tuple2"
                                     ,_0: _v75._0
                                     ,_1: _v75._1} : {ctor: "_Tuple2"
                                                     ,_0: _v75._0
                                                     ,_1: _v75._1 + 1};}
         _E.Case($moduleName,
         "between lines 63 and 65");
      }();
   };
   var moveCursorDown = function (_v79) {
      return function () {
         switch (_v79.ctor)
         {case "_Tuple2":
            return _U.eq(_v79._1,
              0) ? {ctor: "_Tuple2"
                   ,_0: _v79._0
                   ,_1: _v79._1} : {ctor: "_Tuple2"
                                   ,_0: _v79._0
                                   ,_1: _v79._1 - 1};}
         _E.Case($moduleName,
         "between lines 57 and 59");
      }();
   };
   var moveCursorRight = function (_v83) {
      return function () {
         switch (_v83.ctor)
         {case "_Tuple2":
            return _U.eq(_v83._0,
              Board.boardColumns - 2) ? {ctor: "_Tuple2"
                                        ,_0: _v83._0
                                        ,_1: _v83._1} : {ctor: "_Tuple2"
                                                        ,_0: _v83._0 + 1
                                                        ,_1: _v83._1};}
         _E.Case($moduleName,
         "between lines 51 and 53");
      }();
   };
   var moveCursorLeft = function (_v87) {
      return function () {
         switch (_v87.ctor)
         {case "_Tuple2":
            return _U.eq(_v87._0,
              0) ? {ctor: "_Tuple2"
                   ,_0: _v87._0
                   ,_1: _v87._1} : {ctor: "_Tuple2"
                                   ,_0: _v87._0 - 1
                                   ,_1: _v87._1};}
         _E.Case($moduleName,
         "between lines 45 and 47");
      }();
   };
   var gravityConstant = 9.81;
   var matchingTimeInSeconds = 0.1;
   var matchingSpeed = 1.0 / matchingTimeInSeconds;
   var switchingTimeInSeconds = 0.25;
   var switchingSpeed = 1.0 / switchingTimeInSeconds;
   var updateTile = F2(function (timeStep,
   maybeTile) {
      return function () {
         var dt = timeStep;
         return function () {
            switch (maybeTile.ctor)
            {case "Just":
               return function () {
                    switch (maybeTile._0.ctor)
                    {case "_Tuple2":
                       switch (maybeTile._0._1.ctor)
                         {case "Falling":
                            return _U.cmp(maybeTile._0._1._0,
                              1.0) < 0 ? Maybe.Just({ctor: "_Tuple2"
                                                    ,_0: maybeTile._0._0
                                                    ,_1: A2(Board.Falling,
                                                    maybeTile._0._1._0 + dt * maybeTile._0._1._1,
                                                    maybeTile._0._1._1 + dt * gravityConstant)}) : Maybe.Just({ctor: "_Tuple2"
                                                                                                              ,_0: maybeTile._0._0
                                                                                                              ,_1: A2(Board.Fell,
                                                                                                              maybeTile._0._1._0 + dt * maybeTile._0._1._1,
                                                                                                              maybeTile._0._1._1 + dt * gravityConstant)});
                            case "Matching":
                            return _U.cmp(maybeTile._0._1._0,
                              1.0) < 0 ? Maybe.Just({ctor: "_Tuple2"
                                                    ,_0: maybeTile._0._0
                                                    ,_1: Board.Matching(maybeTile._0._1._0 + dt * matchingSpeed)}) : Maybe.Nothing;
                            case "Stationary":
                            return Maybe.Just(maybeTile._0);
                            case "SwitchingLeft":
                            return _U.cmp(maybeTile._0._1._0,
                              1.0) < 0 ? Maybe.Just({ctor: "_Tuple2"
                                                    ,_0: maybeTile._0._0
                                                    ,_1: Board.SwitchingLeft(maybeTile._0._1._0 + dt * switchingSpeed)}) : Maybe.Just({ctor: "_Tuple2"
                                                                                                                                      ,_0: maybeTile._0._0
                                                                                                                                      ,_1: Board.Stationary});
                            case "SwitchingRight":
                            return _U.cmp(maybeTile._0._1._0,
                              1.0) < 0 ? Maybe.Just({ctor: "_Tuple2"
                                                    ,_0: maybeTile._0._0
                                                    ,_1: Board.SwitchingRight(maybeTile._0._1._0 + dt * switchingSpeed)}) : Maybe.Just({ctor: "_Tuple2"
                                                                                                                                       ,_0: maybeTile._0._0
                                                                                                                                       ,_1: Board.Stationary});}
                         break;}
                    _E.Case($moduleName,
                    "between lines 18 and 35");
                 }();
               case "Nothing":
               return Maybe.Nothing;}
            _E.Case($moduleName,
            "between lines 16 and 35");
         }();
      }();
   });
   var updateColumn = function (dt) {
      return List.map(updateTile(dt));
   };
   var updateBoard = function (dt) {
      return List.map(updateColumn(dt));
   };
   var stepGame = F2(function (input,
   _v101) {
      return function () {
         return function () {
            var newTimeStep = function () {
               switch (input.ctor)
               {case "NewTimeStep":
                  return input._0;}
               return _v101.dtOld;
            }();
            var newCursorIdx = function () {
               switch (input.ctor)
               {case "CursorDown":
                  return moveCursorDown(_v101.cursorIdx);
                  case "CursorLeft":
                  return moveCursorLeft(_v101.cursorIdx);
                  case "CursorRight":
                  return moveCursorRight(_v101.cursorIdx);
                  case "CursorUp":
                  return moveCursorUp(_v101.cursorIdx);}
               return _v101.cursorIdx;
            }();
            var swappedBoard = function () {
               switch (input.ctor)
               {case "Swap":
                  return A2(swapTiles,
                    _v101.board,
                    newCursorIdx);}
               return _v101.board;
            }();
            var fallingBoard = updateFalls(swappedBoard);
            var matchedBoard = updateMatches(fallingBoard);
            var newBoard = A2(updateBoard,
            Time.inSeconds(newTimeStep),
            matchedBoard);
            return {_: {}
                   ,board: newBoard
                   ,cursorIdx: newCursorIdx
                   ,dtOld: newTimeStep};
         }();
      }();
   });
   _elm.UpdateBoard.values = {_op: _op
                             ,switchingTimeInSeconds: switchingTimeInSeconds
                             ,switchingSpeed: switchingSpeed
                             ,matchingTimeInSeconds: matchingTimeInSeconds
                             ,matchingSpeed: matchingSpeed
                             ,gravityConstant: gravityConstant
                             ,updateTile: updateTile
                             ,updateColumn: updateColumn
                             ,updateBoard: updateBoard
                             ,moveCursorLeft: moveCursorLeft
                             ,moveCursorRight: moveCursorRight
                             ,moveCursorDown: moveCursorDown
                             ,moveCursorUp: moveCursorUp
                             ,switchable: switchable
                             ,switchTileLeft: switchTileLeft
                             ,switchTileRight: switchTileRight
                             ,swapTiles: swapTiles
                             ,updateFallColumn: updateFallColumn
                             ,updateFalls: updateFalls
                             ,updateMatchesInList: updateMatchesInList
                             ,combineMatches: combineMatches
                             ,updateMatches: updateMatches
                             ,onUp: onUp
                             ,onDown: onDown
                             ,onPressed: onPressed
                             ,onReleased: onReleased
                             ,keyPressed: keyPressed
                             ,input: input
                             ,stepGame: stepGame
                             ,None: None
                             ,CursorLeft: CursorLeft
                             ,CursorRight: CursorRight
                             ,CursorDown: CursorDown
                             ,CursorUp: CursorUp
                             ,Swap: Swap
                             ,NewTimeStep: NewTimeStep};
   return _elm.UpdateBoard.values;
};Elm.PortableBoard = Elm.PortableBoard || {};
Elm.PortableBoard.make = function (_elm) {
   "use strict";
   _elm.PortableBoard = _elm.PortableBoard || {};
   if (_elm.PortableBoard.values)
   return _elm.PortableBoard.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "PortableBoard";
   var Basics = Elm.Basics.make(_elm);
   var Board = Elm.Board.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var Json = Elm.Json.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var jsonToCursor = function (_v0) {
      return function () {
         switch (_v0.ctor)
         {case "Array":
            switch (_v0._0.ctor)
              {case "::":
                 switch (_v0._0._0.ctor)
                   {case "Number":
                      switch (_v0._0._1.ctor)
                        {case "::":
                           switch (_v0._0._1._0.ctor)
                             {case "Number":
                                switch (_v0._0._1._1.ctor)
                                  {case "[]":
                                     return {ctor: "_Tuple2"
                                            ,_0: Basics.round(_v0._0._0._0)
                                            ,_1: Basics.round(_v0._0._1._0._0)};}
                                  break;}
                             break;}
                        break;}
                   break;}
              break;}
         _E.Case($moduleName,
         "on line 50, column 54 to 70");
      }();
   };
   var cursorToJson = function (_v9) {
      return function () {
         switch (_v9.ctor)
         {case "_Tuple2":
            return Json.Array(_L.fromArray([Json.Number(Basics.toFloat(_v9._0))
                                           ,Json.Number(Basics.toFloat(_v9._1))]));}
         _E.Case($moduleName,
         "on line 47, column 22 to 70");
      }();
   };
   var jsonToTile = function (jsonV) {
      return function () {
         switch (jsonV.ctor)
         {case "Array":
            switch (jsonV._0.ctor)
              {case "::":
                 switch (jsonV._0._0.ctor)
                   {case "Number":
                      switch (jsonV._0._1.ctor)
                        {case "::":
                           switch (jsonV._0._1._0.ctor)
                             {case "Number":
                                return function () {
                                     var s = Basics.round(jsonV._0._1._0._0);
                                     var c = Board.colorFromInt(Basics.round(jsonV._0._0._0));
                                     return Maybe.Just(function () {
                                        switch (s)
                                        {case 0: return {ctor: "_Tuple2"
                                                        ,_0: c
                                                        ,_1: Board.Stationary};
                                           case 1: return function () {
                                                var _raw = List.head(jsonV._0._1._1),
                                                $ = _raw.ctor === "Json.Number" ? _raw : _E.Case($moduleName,
                                                "on line 26, column 56 to 63"),
                                                x = $._0;
                                                return {ctor: "_Tuple2"
                                                       ,_0: c
                                                       ,_1: Board.SwitchingLeft(x)};
                                             }();
                                           case 2: return function () {
                                                var _raw = List.head(jsonV._0._1._1),
                                                $ = _raw.ctor === "Json.Number" ? _raw : _E.Case($moduleName,
                                                "on line 27, column 56 to 63"),
                                                x = $._0;
                                                return {ctor: "_Tuple2"
                                                       ,_0: c
                                                       ,_1: Board.SwitchingRight(x)};
                                             }();
                                           case 3: return function () {
                                                var _ = jsonV._0._1._1;
                                                var x = function () {
                                                   switch (_.ctor)
                                                   {case "::":
                                                      switch (_._0.ctor)
                                                        {case "Number":
                                                           switch (_._1.ctor)
                                                             {case "::":
                                                                switch (_._1._0.ctor)
                                                                  {case "Number":
                                                                     switch (_._1._1.ctor)
                                                                       {case "[]":
                                                                          return _._0._0;}
                                                                       break;}
                                                                  break;}
                                                             break;}
                                                        break;}
                                                   _E.Case($moduleName,
                                                   "on line 28, column 74 to 76");
                                                }();
                                                var y = function () {
                                                   switch (_.ctor)
                                                   {case "::":
                                                      switch (_._0.ctor)
                                                        {case "Number":
                                                           switch (_._1.ctor)
                                                             {case "::":
                                                                switch (_._1._0.ctor)
                                                                  {case "Number":
                                                                     switch (_._1._1.ctor)
                                                                       {case "[]":
                                                                          return _._1._0._0;}
                                                                       break;}
                                                                  break;}
                                                             break;}
                                                        break;}
                                                   _E.Case($moduleName,
                                                   "on line 28, column 74 to 76");
                                                }();
                                                return {ctor: "_Tuple2"
                                                       ,_0: c
                                                       ,_1: A2(Board.Falling,
                                                       x,
                                                       y)};
                                             }();
                                           case 4: return function () {
                                                var _ = jsonV._0._1._1;
                                                var x = function () {
                                                   switch (_.ctor)
                                                   {case "::":
                                                      switch (_._0.ctor)
                                                        {case "Number":
                                                           switch (_._1.ctor)
                                                             {case "::":
                                                                switch (_._1._0.ctor)
                                                                  {case "Number":
                                                                     switch (_._1._1.ctor)
                                                                       {case "[]":
                                                                          return _._0._0;}
                                                                       break;}
                                                                  break;}
                                                             break;}
                                                        break;}
                                                   _E.Case($moduleName,
                                                   "on line 30, column 74 to 76");
                                                }();
                                                var y = function () {
                                                   switch (_.ctor)
                                                   {case "::":
                                                      switch (_._0.ctor)
                                                        {case "Number":
                                                           switch (_._1.ctor)
                                                             {case "::":
                                                                switch (_._1._0.ctor)
                                                                  {case "Number":
                                                                     switch (_._1._1.ctor)
                                                                       {case "[]":
                                                                          return _._1._0._0;}
                                                                       break;}
                                                                  break;}
                                                             break;}
                                                        break;}
                                                   _E.Case($moduleName,
                                                   "on line 30, column 74 to 76");
                                                }();
                                                return {ctor: "_Tuple2"
                                                       ,_0: c
                                                       ,_1: A2(Board.Fell,x,y)};
                                             }();
                                           case 5: return function () {
                                                var _raw = List.head(jsonV._0._1._1),
                                                $ = _raw.ctor === "Json.Number" ? _raw : _E.Case($moduleName,
                                                "on line 32, column 56 to 63"),
                                                x = $._0;
                                                return {ctor: "_Tuple2"
                                                       ,_0: c
                                                       ,_1: Board.Matching(x)};
                                             }();}
                                        _E.Case($moduleName,
                                        "between lines 24 and 32");
                                     }());
                                  }();}
                             break;}
                        break;}
                   break;}
              break;
            case "Null":
            return Maybe.Nothing;}
         _E.Case($moduleName,
         "between lines 19 and 32");
      }();
   };
   var jsonToBoard = function (_v50) {
      return function () {
         switch (_v50.ctor)
         {case "Array":
            return function () {
                 var go = F3(function (proc,
                 ts,
                 colsLeft) {
                    return function () {
                       switch (colsLeft)
                       {case 0: return proc;}
                       return function () {
                          var $ = {ctor: "_Tuple2"
                                  ,_0: A2(List.take,
                                  Board.boardRows,
                                  ts)
                                  ,_1: A2(List.drop,
                                  Board.boardRows,
                                  ts)},
                          ts1 = $._0,
                          ts2 = $._1;
                          return A3(go,
                          {ctor: "::",_0: ts1,_1: proc},
                          ts2,
                          colsLeft - 1);
                       }();
                    }();
                 });
                 var mts = A2(List.map,
                 jsonToTile,
                 _v50._0);
                 return List.reverse(A3(go,
                 _L.fromArray([]),
                 mts,
                 Board.boardColumns));
              }();}
         _E.Case($moduleName,
         "between lines 38 and 44");
      }();
   };
   var jsonToState = function (_v54) {
      return function () {
         switch (_v54.ctor)
         {case "Array":
            switch (_v54._0.ctor)
              {case "::":
                 switch (_v54._0._1.ctor)
                   {case "::":
                      switch (_v54._0._1._1.ctor)
                        {case "[]": return {_: {}
                                           ,board: jsonToBoard(_v54._0._0)
                                           ,cursorIdx: jsonToCursor(_v54._0._1._0)
                                           ,dtOld: 0};}
                        break;}
                   break;}
              break;}
         _E.Case($moduleName,
         "on line 57, column 4 to 81");
      }();
   };
   var stringToState = function (str) {
      return function () {
         var _raw = Json.fromString(str),
         $ = _raw.ctor === "Maybe.Just" ? _raw : _E.Case($moduleName,
         "on line 64, column 40 to 54"),
         jsonV = $._0;
         return jsonToState(jsonV);
      }();
   };
   var tileToJson = function (mt) {
      return function () {
         switch (mt.ctor)
         {case "Just":
            switch (mt._0.ctor)
              {case "_Tuple2":
                 return function () {
                      var i = Json.Number(Basics.toFloat(Board.intFromColor(mt._0._0)));
                      return function () {
                         switch (mt._0._1.ctor)
                         {case "Falling":
                            return Json.Array(_L.fromArray([i
                                                           ,Json.Number(3)
                                                           ,Json.Number(mt._0._1._0)
                                                           ,Json.Number(mt._0._1._1)]));
                            case "Fell":
                            return Json.Array(_L.fromArray([i
                                                           ,Json.Number(4)
                                                           ,Json.Number(mt._0._1._0)
                                                           ,Json.Number(mt._0._1._1)]));
                            case "Matching":
                            return Json.Array(_L.fromArray([i
                                                           ,Json.Number(5)
                                                           ,Json.Number(mt._0._1._0)]));
                            case "Stationary":
                            return Json.Array(_L.fromArray([i
                                                           ,Json.Number(0)]));
                            case "SwitchingLeft":
                            return Json.Array(_L.fromArray([i
                                                           ,Json.Number(1)
                                                           ,Json.Number(mt._0._1._0)]));
                            case "SwitchingRight":
                            return Json.Array(_L.fromArray([i
                                                           ,Json.Number(2)
                                                           ,Json.Number(mt._0._1._0)]));}
                         _E.Case($moduleName,
                         "between lines 10 and 16");
                      }();
                   }();}
              break;
            case "Nothing":
            return Json.Null;}
         _E.Case($moduleName,
         "between lines 7 and 16");
      }();
   };
   var boardToJson = function ($) {
      return Json.Array(List.concatMap(List.map(tileToJson))($));
   };
   var stateToJson = function (s) {
      return Json.Array(_L.fromArray([boardToJson(s.board)
                                     ,cursorToJson(s.cursorIdx)]));
   };
   var stateToString = function (s) {
      return Json.toString("")(stateToJson(s));
   };
   _elm.PortableBoard.values = {_op: _op
                               ,tileToJson: tileToJson
                               ,jsonToTile: jsonToTile
                               ,boardToJson: boardToJson
                               ,jsonToBoard: jsonToBoard
                               ,cursorToJson: cursorToJson
                               ,jsonToCursor: jsonToCursor
                               ,stateToJson: stateToJson
                               ,jsonToState: jsonToState
                               ,stateToString: stateToString
                               ,stringToState: stringToState};
   return _elm.PortableBoard.values;
};Elm.DrawBoard = Elm.DrawBoard || {};
Elm.DrawBoard.make = function (_elm) {
   "use strict";
   _elm.DrawBoard = _elm.DrawBoard || {};
   if (_elm.DrawBoard.values)
   return _elm.DrawBoard.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "DrawBoard";
   var Basics = Elm.Basics.make(_elm);
   var Board = Elm.Board.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var cursorPositionFromIdx = F2(function (_v0,
   _v1) {
      return function () {
         switch (_v1.ctor)
         {case "_Tuple2":
            return function () {
                 return function () {
                    var tileHalfSize = _v0.tileSize / 2 | 0;
                    return {ctor: "_Tuple2"
                           ,_0: Basics.toFloat(_v0.lowerLeftX + _v0.tileSize + _v1._0 * _v0.tileSize)
                           ,_1: Basics.toFloat(_v0.lowerLeftY + tileHalfSize + _v1._1 * _v0.tileSize)};
                 }();
              }();}
         _E.Case($moduleName,
         "between lines 48 and 50");
      }();
   });
   var cursorForm = F2(function (bpi,
   leftIdx) {
      return function () {
         var imgForm = Graphics.Collage.toForm(A3(Graphics.Element.image,
         bpi.tileSize * 2,
         bpi.tileSize,
         "resources/cursor.png"));
         return A2(Graphics.Collage.move,
         A2(cursorPositionFromIdx,
         bpi,
         leftIdx),
         imgForm);
      }();
   });
   var smoothStep = function (t) {
      return 6 * Math.pow(t,
      5) - 15 * Math.pow(t,
      4) + 10 * Math.pow(t,3);
   };
   var tileScreenPosition = F3(function (_v6,
   _v7,
   tileState) {
      return function () {
         switch (_v7.ctor)
         {case "_Tuple2":
            return function () {
                 return function () {
                    var offsetY = function () {
                       switch (tileState.ctor)
                       {case "Falling":
                          return _v6.tileSize - Basics.truncate(tileState._0 * Basics.toFloat(_v6.tileSize));
                          case "Fell":
                          return _v6.tileSize - Basics.truncate(tileState._0 * Basics.toFloat(_v6.tileSize));}
                       return 0;
                    }();
                    var offsetX = function () {
                       switch (tileState.ctor)
                       {case "SwitchingLeft":
                          return _v6.tileSize - Basics.truncate(smoothStep(tileState._0) * Basics.toFloat(_v6.tileSize));
                          case "SwitchingRight":
                          return 0 - _v6.tileSize + Basics.truncate(smoothStep(tileState._0) * Basics.toFloat(_v6.tileSize));}
                       return 0;
                    }();
                    var halfSize = _v6.tileSize / 2 | 0;
                    return {ctor: "_Tuple2"
                           ,_0: Basics.toFloat(_v6.lowerLeftX + halfSize + _v7._0 * _v6.tileSize + offsetX)
                           ,_1: Basics.toFloat(_v6.lowerLeftY + halfSize + _v7._1 * _v6.tileSize + offsetY)};
                 }();
              }();}
         _E.Case($moduleName,
         "between lines 23 and 33");
      }();
   });
   var formFromTile = F3(function (_v20,
   tileIdx,
   _v21) {
      return function () {
         switch (_v21.ctor)
         {case "_Tuple2":
            return function () {
                 return function () {
                    var tileImgForm = Graphics.Collage.toForm(A2(Graphics.Element.image,
                    _v20.tileSize,
                    _v20.tileSize)(_L.append("resources/",
                    _L.append(Board.colorToString(_v21._0),
                    ".bmp"))));
                    return A2(Graphics.Collage.move,
                    A3(tileScreenPosition,
                    _v20,
                    tileIdx,
                    _v21._1),
                    tileImgForm);
                 }();
              }();}
         _E.Case($moduleName,
         "between lines 37 and 38");
      }();
   });
   var formsFromBoard = F2(function (bpi,
   b) {
      return function () {
         var mkTileForm = function (_v26) {
            return function () {
               switch (_v26.ctor)
               {case "_Tuple2":
                  return A2(Board.liftMaybe,
                    A2(formFromTile,bpi,_v26._1),
                    _v26._0);}
               _E.Case($moduleName,
               "on line 43, column 29 to 63");
            }();
         };
         var tileIdxs = Board.generateBoardIndices(b);
         return Maybe.justs(A2(List.map,
         mkTileForm,
         tileIdxs));
      }();
   });
   var getBoardPlacementInfo = function (_v30) {
      return function () {
         switch (_v30.ctor)
         {case "_Tuple2":
            return function () {
                 var llY = (0 - _v30._1) / 2 | 0;
                 var heightRatio = 0.9;
                 var tSize = Basics.truncate(heightRatio * Basics.toFloat(_v30._1) / Basics.toFloat(Board.boardRows));
                 var llX = 0 - Basics.truncate(Basics.toFloat(Board.boardColumns) / 2 * Basics.toFloat(tSize));
                 return {_: {}
                        ,lowerLeftX: llX
                        ,lowerLeftY: llY
                        ,tileSize: tSize};
              }();}
         _E.Case($moduleName,
         "between lines 11 and 15");
      }();
   };
   var BoardPlacementInfo = F3(function (a,
   b,
   c) {
      return {_: {}
             ,lowerLeftX: a
             ,lowerLeftY: b
             ,tileSize: c};
   });
   var areaH = 600;
   var areaW = 800;
   var displayGame = F2(function (_v34,
   game) {
      return function () {
         switch (_v34.ctor)
         {case "_Tuple2":
            return function () {
                 var bpi = getBoardPlacementInfo({ctor: "_Tuple2"
                                                 ,_0: areaW
                                                 ,_1: areaH});
                 return A3(Graphics.Element.container,
                 _v34._0,
                 _v34._1,
                 Graphics.Element.middle)(A2(Graphics.Collage.collage,
                 areaW,
                 areaH)(_L.append(_L.fromArray([Graphics.Collage.filled(A3(Color.rgb,
                 0,
                 0,
                 0))(A2(Graphics.Collage.rect,
                 areaW,
                 areaH))]),
                 _L.append(A2(formsFromBoard,
                 bpi,
                 game.board),
                 _L.fromArray([A2(cursorForm,
                 bpi,
                 game.cursorIdx)])))));
              }();}
         _E.Case($moduleName,
         "between lines 59 and 62");
      }();
   });
   _elm.DrawBoard.values = {_op: _op
                           ,areaW: areaW
                           ,areaH: areaH
                           ,getBoardPlacementInfo: getBoardPlacementInfo
                           ,smoothStep: smoothStep
                           ,tileScreenPosition: tileScreenPosition
                           ,formFromTile: formFromTile
                           ,formsFromBoard: formsFromBoard
                           ,cursorPositionFromIdx: cursorPositionFromIdx
                           ,cursorForm: cursorForm
                           ,displayGame: displayGame
                           ,BoardPlacementInfo: BoardPlacementInfo};
   return _elm.DrawBoard.values;
};Elm.Board = Elm.Board || {};
Elm.Board.make = function (_elm) {
   "use strict";
   _elm.Board = _elm.Board || {};
   if (_elm.Board.values)
   return _elm.Board.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Board";
   var Basics = Elm.Basics.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var liftMaybe = F2(function (f,
   m) {
      return function () {
         switch (m.ctor)
         {case "Just":
            return Maybe.Just(f(m._0));
            case "Nothing":
            return Maybe.Nothing;}
         _E.Case($moduleName,
         "between lines 62 and 64");
      }();
   });
   var transpose = function (matrix) {
      return function () {
         switch (matrix.ctor)
         {case "::":
            switch (matrix._0.ctor)
              {case "::": return {ctor: "::"
                                 ,_0: {ctor: "::"
                                      ,_0: matrix._0._0
                                      ,_1: A2(List.map,
                                      List.head,
                                      matrix._1)}
                                 ,_1: transpose({ctor: "::"
                                                ,_0: matrix._0._1
                                                ,_1: A2(List.map,
                                                List.tail,
                                                matrix._1)})};
                 case "[]":
                 return transpose(matrix._1);}
              break;
            case "[]":
            return _L.fromArray([]);}
         _E.Case($moduleName,
         "between lines 56 and 59");
      }();
   };
   var updateAtIdx = F3(function (xs,
   idx,
   x) {
      return function () {
         var go = F4(function (_v7,
         idx,
         x,
         proc) {
            return function () {
               switch (_v7.ctor)
               {case "::": return function () {
                       switch (idx)
                       {case 0: return _L.append(proc,
                            {ctor: "::",_0: x,_1: _v7._1});}
                       return A4(go,
                       _v7._1,
                       idx - 1,
                       x,
                       _L.append(proc,
                       _L.fromArray([_v7._0])));
                    }();}
               _E.Case($moduleName,
               "between lines 44 and 47");
            }();
         });
         return A4(go,
         xs,
         idx,
         x,
         _L.fromArray([]));
      }();
   });
   var listAtIdx = F2(function (xs,
   idx) {
      return function () {
         switch (idx)
         {case 0: return List.head(xs);}
         return A2(listAtIdx,
         List.tail(xs),
         idx - 1);
      }();
   });
   var getTileAt = F2(function (b,
   _v13) {
      return function () {
         switch (_v13.ctor)
         {case "_Tuple2":
            return A2(listAtIdx,
              A2(listAtIdx,b,_v13._0),
              _v13._1);}
         _E.Case($moduleName,
         "on line 50, column 21 to 48");
      }();
   });
   var setTileAt = F3(function (b,
   _v17,
   t) {
      return function () {
         switch (_v17.ctor)
         {case "_Tuple2":
            return A2(updateAtIdx,
              b,
              _v17._0)(A3(updateAtIdx,
              A2(listAtIdx,b,_v17._0),
              _v17._1,
              t));}
         _E.Case($moduleName,
         "on line 53, column 23 to 73");
      }();
   });
   var GameState = F3(function (a,
   b,
   c) {
      return {_: {}
             ,board: a
             ,cursorIdx: b
             ,dtOld: c};
   });
   var Matching = function (a) {
      return {ctor: "Matching"
             ,_0: a};
   };
   var Fell = F2(function (a,b) {
      return {ctor: "Fell"
             ,_0: a
             ,_1: b};
   });
   var Falling = F2(function (a,
   b) {
      return {ctor: "Falling"
             ,_0: a
             ,_1: b};
   });
   var SwitchingRight = function (a) {
      return {ctor: "SwitchingRight"
             ,_0: a};
   };
   var SwitchingLeft = function (a) {
      return {ctor: "SwitchingLeft"
             ,_0: a};
   };
   var Stationary = {ctor: "Stationary"};
   var mkTile = function (c) {
      return {ctor: "_Tuple2"
             ,_0: c
             ,_1: Stationary};
   };
   var Yellow = {ctor: "Yellow"};
   var Green = {ctor: "Green"};
   var Blue = {ctor: "Blue"};
   var Red = {ctor: "Red"};
   var colorIntMap = A2(List.zip,
   _L.range(0,3),
   _L.fromArray([Red
                ,Blue
                ,Green
                ,Yellow]));
   var colorFromInt = function (c) {
      return function () {
         switch (c)
         {case 0: return Red;
            case 1: return Blue;
            case 2: return Green;
            case 3: return Yellow;}
         _E.Case($moduleName,
         "between lines 70 and 74");
      }();
   };
   var intFromColor = function (c) {
      return function () {
         switch (c.ctor)
         {case "Blue": return 1;
            case "Green": return 2;
            case "Red": return 0;
            case "Yellow": return 3;}
         _E.Case($moduleName,
         "between lines 77 and 81");
      }();
   };
   var colorToString = function (c) {
      return function () {
         switch (c.ctor)
         {case "Blue": return "blue";
            case "Green": return "green";
            case "Red": return "red";
            case "Yellow": return "yellow";}
         _E.Case($moduleName,
         "between lines 84 and 88");
      }();
   };
   var boardColumns = 7;
   var boardRows = 12;
   var mkEmptyColumn = A2(List.repeat,
   boardRows,
   Maybe.Nothing);
   var mkEmptyBoard = List.repeat(boardColumns)(mkEmptyColumn);
   var generateColumnIndices = F2(function (column,
   tiles) {
      return A2(List.zip,
      tiles,
      A2(List.zip,
      A2(List.repeat,
      boardRows,
      column),
      _L.range(0,boardRows - 1)));
   });
   var generateBoardIndices = function ($) {
      return List.concat(A2(List.zipWith,
      generateColumnIndices,
      _L.range(0,
      boardColumns - 1))($));
   };
   var boardFromRandomInts = function (fs) {
      return function () {
         var intToTile = function (x) {
            return Maybe.Just(mkTile(colorFromInt(x)));
         };
         var intLists = A3(List.zipWith,
         F2(function (floats,c) {
            return List.take(boardRows)(List.drop(c * boardRows)(floats));
         }),
         A2(List.repeat,boardColumns,fs),
         _L.range(0,boardColumns - 1));
         return A2(List.map,
         List.map(intToTile),
         intLists);
      }();
   };
   _elm.Board.values = {_op: _op
                       ,boardRows: boardRows
                       ,boardColumns: boardColumns
                       ,mkTile: mkTile
                       ,mkEmptyColumn: mkEmptyColumn
                       ,mkEmptyBoard: mkEmptyBoard
                       ,generateColumnIndices: generateColumnIndices
                       ,generateBoardIndices: generateBoardIndices
                       ,listAtIdx: listAtIdx
                       ,updateAtIdx: updateAtIdx
                       ,getTileAt: getTileAt
                       ,setTileAt: setTileAt
                       ,transpose: transpose
                       ,liftMaybe: liftMaybe
                       ,colorIntMap: colorIntMap
                       ,colorFromInt: colorFromInt
                       ,intFromColor: intFromColor
                       ,colorToString: colorToString
                       ,boardFromRandomInts: boardFromRandomInts
                       ,Red: Red
                       ,Blue: Blue
                       ,Green: Green
                       ,Yellow: Yellow
                       ,Stationary: Stationary
                       ,SwitchingLeft: SwitchingLeft
                       ,SwitchingRight: SwitchingRight
                       ,Falling: Falling
                       ,Fell: Fell
                       ,Matching: Matching
                       ,GameState: GameState};
   return _elm.Board.values;
};Elm.Pseudorandom = Elm.Pseudorandom || {};
Elm.Pseudorandom.make = function (_elm) {
   "use strict";
   _elm.Pseudorandom = _elm.Pseudorandom || {};
   if (_elm.Pseudorandom.values)
   return _elm.Pseudorandom.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   $moduleName = "Pseudorandom";
   var Basics = Elm.Basics.make(_elm);
   var Bitwise = Elm.Bitwise.make(_elm);
   var Color = Elm.Color.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Collage = Elm.Graphics.Collage.make(_elm);
   var Graphics = Graphics || {};
   Graphics.Element = Elm.Graphics.Element.make(_elm);
   var List = Elm.List.make(_elm);
   var Maybe = Elm.Maybe.make(_elm);
   var Native = Native || {};
   Native.Json = Elm.Native.Json.make(_elm);
   var Native = Native || {};
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var repeat = F3(function (n,
   f,
   a) {
      return function () {
         switch (n)
         {case 0: return a;}
         return A3(repeat,n - 1,f,f(a));
      }();
   });
   var roundClamp = F2(function (_v1,
   i) {
      return function () {
         switch (_v1.ctor)
         {case "_Tuple2":
            return _v1._0 + A2(Basics.mod,
              i - _v1._0,
              _v1._1 - _v1._0 + 1);}
         _E.Case($moduleName,
         "on line 87, column 23 to 51");
      }();
   });
   var minInt = -2147483648;
   var maxInt = 2147483647;
   var bit32 = 4294967295;
   var c = 5;
   var b = 17;
   var a = 13;
   var xorshift = function (s) {
      return function () {
         var x = A2(Bitwise.xor,
         s,
         A2(Bitwise.shiftLeft,s,a));
         var y = A2(Bitwise.xor,
         x,
         A2(Bitwise.shiftRight,x,b));
         return A2(Bitwise.xor,
         y,
         A2(Bitwise.shiftLeft,y,c));
      }();
   };
   var randomInts = F2(function (n,
   r) {
      return A3(repeat,
      n,
      function (_v5) {
         return function () {
            switch (_v5.ctor)
            {case "_Tuple2":
               return function () {
                    var s$ = xorshift(_v5._1);
                    return {ctor: "_Tuple2"
                           ,_0: {ctor: "::"
                                ,_0: s$
                                ,_1: _v5._0}
                           ,_1: s$};
                 }();}
            _E.Case($moduleName,
            "between lines 75 and 76");
         }();
      },
      {ctor: "_Tuple2"
      ,_0: _L.fromArray([])
      ,_1: r});
   });
   _op[">>="] = F2(function (m,f) {
      return function ($) {
         return Basics.uncurry(f)(m($));
      };
   });
   var chain = F2(function (x,y) {
      return A2(_op[">>="],x,y);
   });
   var pure = function (a) {
      return F2(function (v0,v1) {
         return {ctor: "_Tuple2"
                ,_0: v0
                ,_1: v1};
      })(a);
   };
   var sequence = function (ms) {
      return A3(List.foldr,
      F2(function (m,m$) {
         return A2(_op[">>="],
         m,
         function (x) {
            return A2(_op[">>="],
            m$,
            function ($) {
               return pure(F2(function (x,
               y) {
                  return {ctor: "::"
                         ,_0: x
                         ,_1: y};
               })(x)($));
            });
         });
      }),
      pure(_L.fromArray([])),
      ms);
   };
   var mapM = function (f) {
      return function ($) {
         return sequence(List.map(f)($));
      };
   };
   _op["***"] = F3(function (f,
   g,
   _v9) {
      return function () {
         switch (_v9.ctor)
         {case "_Tuple2":
            return {ctor: "_Tuple2"
                   ,_0: f(_v9._0)
                   ,_1: g(_v9._1)};}
         _E.Case($moduleName,
         "on line 31, column 24 to 32");
      }();
   });
   var randomFloats = function (n) {
      return function ($) {
         return A2(_op["***"],
         List.map(function (n$) {
            return Basics.toFloat(Basics.abs(n$) - 1) / (0 - minInt);
         }),
         Basics.id)(randomInts(n)($));
      };
   };
   var randomRange = F2(function (rn,
   n) {
      return function ($) {
         return A2(_op["***"],
         List.map(roundClamp(rn)),
         Basics.id)(randomInts(n)($));
      };
   });
   _elm.Pseudorandom.values = {_op: _op
                              ,pure: pure
                              ,chain: chain
                              ,sequence: sequence
                              ,mapM: mapM
                              ,randomInts: randomInts
                              ,randomFloats: randomFloats
                              ,randomRange: randomRange};
   return _elm.Pseudorandom.values;
};