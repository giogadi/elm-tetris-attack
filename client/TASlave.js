Elm.Slave = Elm.Slave || {};
Elm.Slave.make = function (_elm) {
   "use strict";
   _elm.Slave = _elm.Slave || {};
   if (_elm.Slave.values)
   return _elm.Slave.values;
   var _N = Elm.Native,
   _U = _N.Utils.make(_elm),
   _L = _N.List.make(_elm),
   _E = _N.Error.make(_elm),
   _J = _N.JavaScript.make(_elm),
   $moduleName = "Slave";
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
   Native.Ports = Elm.Native.Ports.make(_elm);
   var PortableBoard = Elm.PortableBoard.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var Window = Elm.Window.make(_elm);
   var _op = {};
   var gameStateIn = Native.Ports.portIn("gameStateIn",
   Native.Ports.incomingSignal(function (v) {
      return typeof v === "object" && v instanceof Array ? {ctor: "_Tuple2"
                                                           ,_0: typeof v[0] === "object" && v[0] instanceof Array ? _J.toList(v[0].map(function (v) {
                                                              return typeof v === "object" && v instanceof Array ? _J.toList(v.map(function (v) {
                                                                 return v === null ? Maybe.Nothing : Maybe.Just(typeof v === "object" && v instanceof Array ? {ctor: "_Tuple4"
                                                                                                                                                              ,_0: typeof v[0] === "number" ? _J.toInt(v[0]) : _E.raise("invalid input, expecting JSNumber but got " + v[0])
                                                                                                                                                              ,_1: typeof v[1] === "number" ? _J.toInt(v[1]) : _E.raise("invalid input, expecting JSNumber but got " + v[1])
                                                                                                                                                              ,_2: typeof v[2] === "number" ? _J.toFloat(v[2]) : _E.raise("invalid input, expecting JSNumber but got " + v[2])
                                                                                                                                                              ,_3: typeof v[3] === "number" ? _J.toFloat(v[3]) : _E.raise("invalid input, expecting JSNumber but got " + v[3])} : _E.raise("invalid input, expecting JSArray but got " + v));
                                                              })) : _E.raise("invalid input, expecting JSArray but got " + v);
                                                           })) : _E.raise("invalid input, expecting JSArray but got " + v[0])
                                                           ,_1: typeof v[1] === "object" && v[1] instanceof Array ? {ctor: "_Tuple2"
                                                                                                                    ,_0: typeof v[1][0] === "number" ? _J.toInt(v[1][0]) : _E.raise("invalid input, expecting JSNumber but got " + v[1][0])
                                                                                                                    ,_1: typeof v[1][1] === "number" ? _J.toInt(v[1][1]) : _E.raise("invalid input, expecting JSNumber but got " + v[1][1])} : _E.raise("invalid input, expecting JSArray but got " + v[1])} : _E.raise("invalid input, expecting JSArray but got " + v);
   }));
   var main = A3(Signal.lift2,
   DrawBoard.displayGame,
   Window.dimensions,
   A2(Signal.lift,
   PortableBoard.fromPortableState,
   gameStateIn));
   _elm.Slave.values = {_op: _op
                       ,main: main};
   return _elm.Slave.values;
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
   _J = _N.JavaScript.make(_elm),
   $moduleName = "PortableBoard";
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
   Native.Ports = Elm.Native.Ports.make(_elm);
   var Signal = Elm.Signal.make(_elm);
   var String = Elm.String.make(_elm);
   var Text = Elm.Text.make(_elm);
   var Time = Elm.Time.make(_elm);
   var _op = {};
   var fromPortableTile = function (_v0) {
      return function () {
         switch (_v0.ctor)
         {case "_Tuple4":
            return function () {
                 var c = Board.colorFromInt(_v0._0);
                 return function () {
                    switch (_v0._1)
                    {case 0: return {ctor: "_Tuple2"
                                    ,_0: c
                                    ,_1: Board.Stationary};
                       case 1: return {ctor: "_Tuple2"
                                      ,_0: c
                                      ,_1: Board.SwitchingLeft(_v0._2)};
                       case 2: return {ctor: "_Tuple2"
                                      ,_0: c
                                      ,_1: Board.SwitchingRight(_v0._2)};
                       case 3: return {ctor: "_Tuple2"
                                      ,_0: c
                                      ,_1: A2(Board.Falling,
                                      _v0._2,
                                      _v0._3)};
                       case 4: return {ctor: "_Tuple2"
                                      ,_0: c
                                      ,_1: A2(Board.Fell,
                                      _v0._2,
                                      _v0._3)};
                       case 5: return {ctor: "_Tuple2"
                                      ,_0: c
                                      ,_1: Board.Matching(_v0._2)};}
                    _E.Case($moduleName,
                    "between lines 21 and 27");
                 }();
              }();}
         _E.Case($moduleName,
         "between lines 20 and 27");
      }();
   };
   var fromPortableBoard = List.map(List.map(Board.liftMaybe(fromPortableTile)));
   var fromPortableState = function (_v7) {
      return function () {
         switch (_v7.ctor)
         {case "_Tuple2": return {_: {}
                                 ,board: fromPortableBoard(_v7._0)
                                 ,cursorIdx: _v7._1
                                 ,dtOld: 0};}
         _E.Case($moduleName,
         "on line 39, column 29 to 78");
      }();
   };
   var toPortableTile = function (_v11) {
      return function () {
         switch (_v11.ctor)
         {case "_Tuple2":
            return function () {
                 var i = Board.intFromColor(_v11._0);
                 return function () {
                    switch (_v11._1.ctor)
                    {case "Falling":
                       return {ctor: "_Tuple4"
                              ,_0: i
                              ,_1: 3
                              ,_2: _v11._1._0
                              ,_3: _v11._1._1};
                       case "Fell":
                       return {ctor: "_Tuple4"
                              ,_0: i
                              ,_1: 4
                              ,_2: _v11._1._0
                              ,_3: _v11._1._1};
                       case "Matching":
                       return {ctor: "_Tuple4"
                              ,_0: i
                              ,_1: 5
                              ,_2: _v11._1._0
                              ,_3: 0};
                       case "Stationary":
                       return {ctor: "_Tuple4"
                              ,_0: i
                              ,_1: 0
                              ,_2: 0
                              ,_3: 0};
                       case "SwitchingLeft":
                       return {ctor: "_Tuple4"
                              ,_0: i
                              ,_1: 1
                              ,_2: _v11._1._0
                              ,_3: 0};
                       case "SwitchingRight":
                       return {ctor: "_Tuple4"
                              ,_0: i
                              ,_1: 2
                              ,_2: _v11._1._0
                              ,_3: 0};}
                    _E.Case($moduleName,
                    "between lines 11 and 17");
                 }();
              }();}
         _E.Case($moduleName,
         "between lines 10 and 17");
      }();
   };
   var toPortableBoard = List.map(List.map(Board.liftMaybe(toPortableTile)));
   var toPortableState = function (s) {
      return {ctor: "_Tuple2"
             ,_0: toPortableBoard(s.board)
             ,_1: s.cursorIdx};
   };
   _elm.PortableBoard.values = {_op: _op
                               ,toPortableTile: toPortableTile
                               ,fromPortableTile: fromPortableTile
                               ,toPortableBoard: toPortableBoard
                               ,fromPortableBoard: fromPortableBoard
                               ,toPortableState: toPortableState
                               ,fromPortableState: fromPortableState};
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
   _J = _N.JavaScript.make(_elm),
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
                 areaH)(_L.append(_J.toList([Graphics.Collage.filled(A3(Color.rgb,
                 0,
                 0,
                 0))(A2(Graphics.Collage.rect,
                 areaW,
                 areaH))]),
                 _L.append(A2(formsFromBoard,
                 bpi,
                 game.board),
                 _J.toList([A2(cursorForm,
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
   _J = _N.JavaScript.make(_elm),
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
            return _J.toList([]);}
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
                       _J.toList([_v7._0])));
                    }();}
               _E.Case($moduleName,
               "between lines 44 and 47");
            }();
         });
         return A4(go,
         xs,
         idx,
         x,
         _J.toList([]));
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
   _J.toList([Red
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
};