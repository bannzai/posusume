// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class SpotsQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query Spots($spotsMinLatitude: Latitude!, $spotsMinLongitude: Longitude!, $spotsMaxLatitude: Latitude!, $spotsMaxLongitude: Longitude!) {
      spots(
        minLatitude: $spotsMinLatitude
        minLongitude: $spotsMinLongitude
        maxLatitude: $spotsMaxLatitude
        maxLongitude: $spotsMaxLongitude
      ) {
        __typename
        id
        geoPoint {
          __typename
          latitude
          longitude
        }
        ...SpotMapImageFragment
      }
    }
    """

  public let operationName: String = "Spots"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + SpotMapImageFragment.fragmentDefinition)
    return document
  }

  public var spotsMinLatitude: Latitude
  public var spotsMinLongitude: Longitude
  public var spotsMaxLatitude: Latitude
  public var spotsMaxLongitude: Longitude

  public init(spotsMinLatitude: Latitude, spotsMinLongitude: Longitude, spotsMaxLatitude: Latitude, spotsMaxLongitude: Longitude) {
    self.spotsMinLatitude = spotsMinLatitude
    self.spotsMinLongitude = spotsMinLongitude
    self.spotsMaxLatitude = spotsMaxLatitude
    self.spotsMaxLongitude = spotsMaxLongitude
  }

  public var variables: GraphQLMap? {
    return ["spotsMinLatitude": spotsMinLatitude, "spotsMinLongitude": spotsMinLongitude, "spotsMaxLatitude": spotsMaxLatitude, "spotsMaxLongitude": spotsMaxLongitude]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("spots", arguments: ["minLatitude": GraphQLVariable("spotsMinLatitude"), "minLongitude": GraphQLVariable("spotsMinLongitude"), "maxLatitude": GraphQLVariable("spotsMaxLatitude"), "maxLongitude": GraphQLVariable("spotsMaxLongitude")], type: .nonNull(.list(.nonNull(.object(Spot.selections))))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(spots: [Spot]) {
      self.init(unsafeResultMap: ["__typename": "Query", "spots": spots.map { (value: Spot) -> ResultMap in value.resultMap }])
    }

    public var spots: [Spot] {
      get {
        return (resultMap["spots"] as! [ResultMap]).map { (value: ResultMap) -> Spot in Spot(unsafeResultMap: value) }
      }
      set {
        resultMap.updateValue(newValue.map { (value: Spot) -> ResultMap in value.resultMap }, forKey: "spots")
      }
    }

    public struct Spot: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Spot"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("geoPoint", type: .nonNull(.object(GeoPoint.selections))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("imageURL", type: .nonNull(.scalar(URL.self))),
          GraphQLField("resizedSpotImageURLs", type: .nonNull(.object(ResizedSpotImageUrl.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, geoPoint: GeoPoint, imageUrl: URL, resizedSpotImageUrLs: ResizedSpotImageUrl) {
        self.init(unsafeResultMap: ["__typename": "Spot", "id": id, "geoPoint": geoPoint.resultMap, "imageURL": imageUrl, "resizedSpotImageURLs": resizedSpotImageUrLs.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var geoPoint: GeoPoint {
        get {
          return GeoPoint(unsafeResultMap: resultMap["geoPoint"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "geoPoint")
        }
      }

      public var imageUrl: URL {
        get {
          return resultMap["imageURL"]! as! URL
        }
        set {
          resultMap.updateValue(newValue, forKey: "imageURL")
        }
      }

      public var resizedSpotImageUrLs: ResizedSpotImageUrl {
        get {
          return ResizedSpotImageUrl(unsafeResultMap: resultMap["resizedSpotImageURLs"]! as! ResultMap)
        }
        set {
          resultMap.updateValue(newValue.resultMap, forKey: "resizedSpotImageURLs")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var spotMapImageFragment: SpotMapImageFragment {
          get {
            return SpotMapImageFragment(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct GeoPoint: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["GeoPoint"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("latitude", type: .nonNull(.scalar(Latitude.self))),
            GraphQLField("longitude", type: .nonNull(.scalar(Longitude.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(latitude: Latitude, longitude: Longitude) {
          self.init(unsafeResultMap: ["__typename": "GeoPoint", "latitude": latitude, "longitude": longitude])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var latitude: Latitude {
          get {
            return resultMap["latitude"]! as! Latitude
          }
          set {
            resultMap.updateValue(newValue, forKey: "latitude")
          }
        }

        public var longitude: Longitude {
          get {
            return resultMap["longitude"]! as! Longitude
          }
          set {
            resultMap.updateValue(newValue, forKey: "longitude")
          }
        }
      }

      public struct ResizedSpotImageUrl: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["ResizedSpotImageURLs"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("thumbnail", type: .scalar(URL.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(thumbnail: URL? = nil) {
          self.init(unsafeResultMap: ["__typename": "ResizedSpotImageURLs", "thumbnail": thumbnail])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var thumbnail: URL? {
          get {
            return resultMap["thumbnail"] as? URL
          }
          set {
            resultMap.updateValue(newValue, forKey: "thumbnail")
          }
        }
      }
    }
  }
}

public struct SpotMapImageFragment: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment SpotMapImageFragment on Spot {
      __typename
      id
      imageURL
      resizedSpotImageURLs {
        __typename
        thumbnail
      }
    }
    """

  public static let possibleTypes: [String] = ["Spot"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("imageURL", type: .nonNull(.scalar(URL.self))),
      GraphQLField("resizedSpotImageURLs", type: .nonNull(.object(ResizedSpotImageUrl.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: GraphQLID, imageUrl: URL, resizedSpotImageUrLs: ResizedSpotImageUrl) {
    self.init(unsafeResultMap: ["__typename": "Spot", "id": id, "imageURL": imageUrl, "resizedSpotImageURLs": resizedSpotImageUrLs.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var id: GraphQLID {
    get {
      return resultMap["id"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "id")
    }
  }

  public var imageUrl: URL {
    get {
      return resultMap["imageURL"]! as! URL
    }
    set {
      resultMap.updateValue(newValue, forKey: "imageURL")
    }
  }

  public var resizedSpotImageUrLs: ResizedSpotImageUrl {
    get {
      return ResizedSpotImageUrl(unsafeResultMap: resultMap["resizedSpotImageURLs"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "resizedSpotImageURLs")
    }
  }

  public struct ResizedSpotImageUrl: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["ResizedSpotImageURLs"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("thumbnail", type: .scalar(URL.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(thumbnail: URL? = nil) {
      self.init(unsafeResultMap: ["__typename": "ResizedSpotImageURLs", "thumbnail": thumbnail])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var thumbnail: URL? {
      get {
        return resultMap["thumbnail"] as? URL
      }
      set {
        resultMap.updateValue(newValue, forKey: "thumbnail")
      }
    }
  }
}