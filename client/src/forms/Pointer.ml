open Prelude

(* Dark *)
module B = BlankOr

(* ------------------------ *)
(* PointerData *)
(* ------------------------ *)

let typeOf (pd : blankOrData) : blankOrType =
  match pd with
  | PEventModifier _ ->
      EventModifier
  | PEventName _ ->
      EventName
  | PEventSpace _ ->
      EventSpace
  | PDBName _ ->
      DBName
  | PDBColName _ ->
      DBColName
  | PDBColType _ ->
      DBColType
  | PFnName _ ->
      FnName
  | PParamName _ ->
      ParamName
  | PParamTipe _ ->
      ParamTipe
  | PTypeName _ ->
      TypeName
  | PTypeFieldName _ ->
      TypeFieldName
  | PTypeFieldTipe _ ->
      TypeFieldTipe
  | PGroupName _ ->
      GroupName


let emptyD (pt : blankOrType) : blankOrData =
  let id = gid () in
  match pt with
  | EventModifier ->
      PEventModifier (Blank id)
  | EventName ->
      PEventName (Blank id)
  | EventSpace ->
      PEventSpace (Blank id)
  | DBName ->
      PDBName (Blank id)
  | DBColName ->
      PDBColName (Blank id)
  | DBColType ->
      PDBColType (Blank id)
  | FnName ->
      PFnName (Blank id)
  | ParamName ->
      PParamName (Blank id)
  | ParamTipe ->
      PParamTipe (Blank id)
  | TypeName ->
      PTypeName (Blank id)
  | TypeFieldName ->
      PTypeFieldName (Blank id)
  | TypeFieldTipe ->
      PTypeFieldTipe (Blank id)
  | GroupName ->
      PGroupName (Blank id)


let toID (pd : blankOrData) : ID.t =
  match pd with
  | PEventModifier d ->
      B.toID d
  | PEventName d ->
      B.toID d
  | PEventSpace d ->
      B.toID d
  | PDBName d ->
      B.toID d
  | PDBColName d ->
      B.toID d
  | PDBColType d ->
      B.toID d
  | PFnName d ->
      B.toID d
  | PParamName d ->
      B.toID d
  | PParamTipe d ->
      B.toID d
  | PTypeName d ->
      B.toID d
  | PTypeFieldName d ->
      B.toID d
  | PTypeFieldTipe d ->
      B.toID d
  | PGroupName d ->
      B.toID d


let isBlank (pd : blankOrData) : bool =
  match pd with
  | PEventModifier d
  | PEventName d
  | PEventSpace d
  | PDBName d
  | PDBColName d
  | PDBColType d
  | PFnName d
  | PParamName d
  | PTypeName d
  | PTypeFieldName d
  | PGroupName d ->
      B.isBlank d
  | PTypeFieldTipe d | PParamTipe d ->
      B.isBlank d


let strMap (pd : blankOrData) ~(f : string -> string) : blankOrData =
  let bf s =
    match s with
    | Blank _ ->
      (match f "" with "" -> s | other -> B.newF other)
    | F (id, str) ->
        F (id, f str)
  in
  match pd with
  | PEventModifier d ->
      PEventModifier (bf d)
  | PEventName d ->
      PEventName (bf d)
  | PEventSpace d ->
      PEventSpace (bf d)
  | PDBName d ->
      PDBName (bf d)
  | PDBColName d ->
      PDBColName (bf d)
  | PDBColType d ->
      PDBColType (bf d)
  | PFnName d ->
      PFnName (bf d)
  | PParamName d ->
      PParamName (bf d)
  | PParamTipe d ->
      PParamTipe d
  | PTypeName d ->
      PTypeName (bf d)
  | PTypeFieldName d ->
      PTypeFieldName (bf d)
  | PTypeFieldTipe d ->
      PTypeFieldTipe d
  | PGroupName g ->
      PGroupName (bf g)


let toContent (pd : blankOrData) : string =
  let bs2s s = s |> B.toOption |> Option.withDefault ~default:"" in
  match pd with
  | PEventModifier d ->
      bs2s d
  | PEventName d ->
      bs2s d
  | PEventSpace d ->
      bs2s d
  | PDBName d ->
      bs2s d
  | PDBColName d ->
      bs2s d
  | PDBColType d ->
      bs2s d
  | PFnName d ->
      bs2s d
  | PParamName d ->
      bs2s d
  | PParamTipe d ->
      d
      |> B.toOption
      |> Option.map ~f:Runtime.tipe2str
      |> Option.withDefault ~default:""
  | PTypeName d ->
      bs2s d
  | PTypeFieldName d ->
      bs2s d
  | PTypeFieldTipe d ->
      d
      |> B.toOption
      |> Option.map ~f:Runtime.tipe2str
      |> Option.withDefault ~default:""
  | PGroupName g ->
      bs2s g
