// Code generated by timoni. DO NOT EDIT.

//timoni:generate timoni vendor crd -f https://github.com/envoyproxy/gateway/releases/download/v1.3.0/install.yaml

package v1alpha2

import (
	"strings"
	"list"
)

// TCPRoute provides a way to route TCP requests. When combined
// with a Gateway
// listener, it can be used to forward connections on the port
// specified by the
// listener to a set of backends specified by the TCPRoute.
#TCPRoute: {
	// APIVersion defines the versioned schema of this representation
	// of an object.
	// Servers should convert recognized schemas to the latest
	// internal value, and
	// may reject unrecognized values.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
	apiVersion: "gateway.networking.k8s.io/v1alpha2"

	// Kind is a string value representing the REST resource this
	// object represents.
	// Servers may infer this from the endpoint the client submits
	// requests to.
	// Cannot be updated.
	// In CamelCase.
	// More info:
	// https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
	kind: "TCPRoute"
	metadata!: {
		name!: strings.MaxRunes(253) & strings.MinRunes(1) & {
			string
		}
		namespace!: strings.MaxRunes(63) & strings.MinRunes(1) & {
			string
		}
		labels?: {
			[string]: string
		}
		annotations?: {
			[string]: string
		}
	}

	// Spec defines the desired state of TCPRoute.
	spec!: #TCPRouteSpec
}

// Spec defines the desired state of TCPRoute.
#TCPRouteSpec: {
	// ParentRefs references the resources (usually Gateways) that a
	// Route wants
	// to be attached to. Note that the referenced parent resource
	// needs to
	// allow this for the attachment to be complete. For Gateways,
	// that means
	// the Gateway needs to allow attachment from Routes of this kind
	// and
	// namespace. For Services, that means the Service must either be
	// in the same
	// namespace for a "producer" route, or the mesh implementation
	// must support
	// and allow "consumer" routes for the referenced Service.
	// ReferenceGrant is
	// not applicable for governing ParentRefs to Services - it is not
	// possible to
	// create a "producer" route for a Service in a different
	// namespace from the
	// Route.
	//
	// There are two kinds of parent resources with "Core" support:
	//
	// * Gateway (Gateway conformance profile)
	// * Service (Mesh conformance profile, ClusterIP Services only)
	//
	// This API may be extended in the future to support additional
	// kinds of parent
	// resources.
	//
	// ParentRefs must be _distinct_. This means either that:
	//
	// * They select different objects. If this is the case, then
	// parentRef
	// entries are distinct. In terms of fields, this means that the
	// multi-part key defined by `group`, `kind`, `namespace`, and
	// `name` must
	// be unique across all parentRef entries in the Route.
	// * They do not select different objects, but for each optional
	// field used,
	// each ParentRef that selects the same object must set the same
	// set of
	// optional fields to different values. If one ParentRef sets a
	// combination of optional fields, all must set the same
	// combination.
	//
	// Some examples:
	//
	// * If one ParentRef sets `sectionName`, all ParentRefs
	// referencing the
	// same object must also set `sectionName`.
	// * If one ParentRef sets `port`, all ParentRefs referencing the
	// same
	// object must also set `port`.
	// * If one ParentRef sets `sectionName` and `port`, all
	// ParentRefs
	// referencing the same object must also set `sectionName` and
	// `port`.
	//
	// It is possible to separately reference multiple distinct
	// objects that may
	// be collapsed by an implementation. For example, some
	// implementations may
	// choose to merge compatible Gateway Listeners together. If that
	// is the
	// case, the list of routes attached to those resources should
	// also be
	// merged.
	//
	// Note that for ParentRefs that cross namespace boundaries, there
	// are specific
	// rules. Cross-namespace references are only valid if they are
	// explicitly
	// allowed by something in the namespace they are referring to.
	// For example,
	// Gateway has the AllowedRoutes field, and ReferenceGrant
	// provides a
	// generic way to enable other kinds of cross-namespace reference.
	//
	//
	// ParentRefs from a Route to a Service in the same namespace are
	// "producer"
	// routes, which apply default routing rules to inbound
	// connections from
	// any namespace to the Service.
	//
	// ParentRefs from a Route to a Service in a different namespace
	// are
	// "consumer" routes, and these routing rules are only applied to
	// outbound
	// connections originating from the same namespace as the Route,
	// for which
	// the intended destination of the connections are a Service
	// targeted as a
	// ParentRef of the Route.
	parentRefs?: list.MaxItems(32) & [...{
		// Group is the group of the referent.
		// When unspecified, "gateway.networking.k8s.io" is inferred.
		// To set the core API group (such as for a "Service" kind
		// referent),
		// Group must be explicitly set to "" (empty string).
		//
		// Support: Core
		group?: strings.MaxRunes(253) & =~"^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$" | *"gateway.networking.k8s.io"

		// Kind is kind of the referent.
		//
		// There are two kinds of parent resources with "Core" support:
		//
		// * Gateway (Gateway conformance profile)
		// * Service (Mesh conformance profile, ClusterIP Services only)
		//
		// Support for other resources is Implementation-Specific.
		kind?: strings.MaxRunes(63) & strings.MinRunes(1) & =~"^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$" | *"Gateway"

		// Name is the name of the referent.
		//
		// Support: Core
		name!: strings.MaxRunes(253) & strings.MinRunes(1)

		// Namespace is the namespace of the referent. When unspecified,
		// this refers
		// to the local namespace of the Route.
		//
		// Note that there are specific rules for ParentRefs which cross
		// namespace
		// boundaries. Cross-namespace references are only valid if they
		// are explicitly
		// allowed by something in the namespace they are referring to.
		// For example:
		// Gateway has the AllowedRoutes field, and ReferenceGrant
		// provides a
		// generic way to enable any other kind of cross-namespace
		// reference.
		//
		//
		// ParentRefs from a Route to a Service in the same namespace are
		// "producer"
		// routes, which apply default routing rules to inbound
		// connections from
		// any namespace to the Service.
		//
		// ParentRefs from a Route to a Service in a different namespace
		// are
		// "consumer" routes, and these routing rules are only applied to
		// outbound
		// connections originating from the same namespace as the Route,
		// for which
		// the intended destination of the connections are a Service
		// targeted as a
		// ParentRef of the Route.
		//
		//
		// Support: Core
		namespace?: strings.MaxRunes(63) & strings.MinRunes(1) & {
			=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
		}

		// Port is the network port this Route targets. It can be
		// interpreted
		// differently based on the type of parent resource.
		//
		// When the parent resource is a Gateway, this targets all
		// listeners
		// listening on the specified port that also support this kind of
		// Route(and
		// select this Route). It's not recommended to set `Port` unless
		// the
		// networking behaviors specified in a Route must apply to a
		// specific port
		// as opposed to a listener(s) whose port(s) may be changed. When
		// both Port
		// and SectionName are specified, the name and port of the
		// selected listener
		// must match both specified values.
		//
		//
		// When the parent resource is a Service, this targets a specific
		// port in the
		// Service spec. When both Port (experimental) and SectionName are
		// specified,
		// the name and port of the selected port must match both
		// specified values.
		//
		//
		// Implementations MAY choose to support other parent resources.
		// Implementations supporting other types of parent resources MUST
		// clearly
		// document how/if Port is interpreted.
		//
		// For the purpose of status, an attachment is considered
		// successful as
		// long as the parent resource accepts it partially. For example,
		// Gateway
		// listeners can restrict which Routes can attach to them by Route
		// kind,
		// namespace, or hostname. If 1 of 2 Gateway listeners accept
		// attachment
		// from the referencing Route, the Route MUST be considered
		// successfully
		// attached. If no Gateway listeners accept attachment from this
		// Route,
		// the Route MUST be considered detached from the Gateway.
		//
		// Support: Extended
		port?: uint16 & >=1

		// SectionName is the name of a section within the target
		// resource. In the
		// following resources, SectionName is interpreted as the
		// following:
		//
		// * Gateway: Listener name. When both Port (experimental) and
		// SectionName
		// are specified, the name and port of the selected listener must
		// match
		// both specified values.
		// * Service: Port name. When both Port (experimental) and
		// SectionName
		// are specified, the name and port of the selected listener must
		// match
		// both specified values.
		//
		// Implementations MAY choose to support attaching Routes to other
		// resources.
		// If that is the case, they MUST clearly document how SectionName
		// is
		// interpreted.
		//
		// When unspecified (empty string), this will reference the entire
		// resource.
		// For the purpose of status, an attachment is considered
		// successful if at
		// least one section in the parent resource accepts it. For
		// example, Gateway
		// listeners can restrict which Routes can attach to them by Route
		// kind,
		// namespace, or hostname. If 1 of 2 Gateway listeners accept
		// attachment from
		// the referencing Route, the Route MUST be considered
		// successfully
		// attached. If no Gateway listeners accept attachment from this
		// Route, the
		// Route MUST be considered detached from the Gateway.
		//
		// Support: Core
		sectionName?: strings.MaxRunes(253) & strings.MinRunes(1) & {
			=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"
		}
	}]

	// Rules are a list of TCP matchers and actions.
	rules!: list.MaxItems(16) & [...{
		// BackendRefs defines the backend(s) where matching requests
		// should be
		// sent. If unspecified or invalid (refers to a non-existent
		// resource or a
		// Service with no endpoints), the underlying implementation MUST
		// actively
		// reject connection attempts to this backend. Connection
		// rejections must
		// respect weight; if an invalid backend is requested to have 80%
		// of
		// connections, then 80% of connections must be rejected instead.
		//
		// Support: Core for Kubernetes Service
		//
		// Support: Extended for Kubernetes ServiceImport
		//
		// Support: Implementation-specific for any other resource
		//
		// Support for weight: Extended
		backendRefs?: list.MaxItems(16) & [...{
			// Group is the group of the referent. For example,
			// "gateway.networking.k8s.io".
			// When unspecified or empty string, core API group is inferred.
			group?: strings.MaxRunes(253) & =~"^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$" | *""

			// Kind is the Kubernetes resource kind of the referent. For
			// example
			// "Service".
			//
			// Defaults to "Service" when not specified.
			//
			// ExternalName services can refer to CNAME DNS records that may
			// live
			// outside of the cluster and as such are difficult to reason
			// about in
			// terms of conformance. They also may not be safe to forward to
			// (see
			// CVE-2021-25740 for more information). Implementations SHOULD
			// NOT
			// support ExternalName Services.
			//
			// Support: Core (Services with a type other than ExternalName)
			//
			// Support: Implementation-specific (Services with type
			// ExternalName)
			kind?: strings.MaxRunes(63) & strings.MinRunes(1) & =~"^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$" | *"Service"

			// Name is the name of the referent.
			name!: strings.MaxRunes(253) & strings.MinRunes(1)

			// Namespace is the namespace of the backend. When unspecified,
			// the local
			// namespace is inferred.
			//
			// Note that when a namespace different than the local namespace
			// is specified,
			// a ReferenceGrant object is required in the referent namespace
			// to allow that
			// namespace's owner to accept the reference. See the
			// ReferenceGrant
			// documentation for details.
			//
			// Support: Core
			namespace?: strings.MaxRunes(63) & strings.MinRunes(1) & {
				=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
			}

			// Port specifies the destination port number to use for this
			// resource.
			// Port is required when the referent is a Kubernetes Service. In
			// this
			// case, the port number is the service port number, not the
			// target port.
			// For other resources, destination port might be derived from the
			// referent
			// resource or this field.
			port?: uint16 & >=1

			// Weight specifies the proportion of requests forwarded to the
			// referenced
			// backend. This is computed as weight/(sum of all weights in this
			// BackendRefs list). For non-zero values, there may be some
			// epsilon from
			// the exact proportion defined here depending on the precision an
			// implementation supports. Weight is not a percentage and the sum
			// of
			// weights does not need to equal 100.
			//
			// If only one backend is specified and it has a weight greater
			// than 0, 100%
			// of the traffic is forwarded to that backend. If weight is set
			// to 0, no
			// traffic should be forwarded for this entry. If unspecified,
			// weight
			// defaults to 1.
			//
			// Support for this field varies based on the context where used.
			weight?: int32 & int & <=1000000 & >=0 | *1
		}] & [_, ...]

		// Name is the name of the route rule. This name MUST be unique
		// within a Route if it is set.
		//
		// Support: Extended
		name?: strings.MaxRunes(253) & strings.MinRunes(1) & {
			=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"
		}
	}] & [_, ...]
}
