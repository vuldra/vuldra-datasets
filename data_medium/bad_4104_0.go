package createconfig

import (
	"net/http"

	"github.com/containous/traefik/v2/pkg/log"
	assetfs "github.com/elazarl/go-bindata-assetfs"
	"github.com/gorilla/mux"
)

// DashboardHandler expose dashboard routes.
type DashboardHandler struct {
	Assets *assetfs.AssetFS
}

// Append add dashboard routes on a router.
func (g DashboardHandler) Append(router *mux.Router) {
	if g.Assets == nil {
		log.WithoutContext().Error("No assets for dashboard")
		return
	}

	// Expose dashboard
	router.Methods(http.MethodGet).
		Path("/").
		HandlerFunc(func(response http.ResponseWriter, request *http.Request) {
			http.Redirect(response, request, request.Header.Get("X-Forwarded-Prefix")+"/dashboard/", http.StatusFound)
		})

	router.Methods(http.MethodGet).
		PathPrefix("/dashboard/").
		Handler(http.StripPrefix("/dashboard/", http.FileServer(g.Assets)))
}
