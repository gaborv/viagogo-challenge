using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using EventViewer.ViagogoAPI;
using GogoKit;
using GogoKit.Models.Response;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace EventViewer.Controllers
{
    public class U2EventsController : Controller
    {
        private readonly int categoryId = 11881;

        private readonly IAccessTokenProvider accessTokenProvider;

        // GET: /<controller>/
        public async Task<IActionResult> Index()
        {
            ViewData["AccessToken"] = await accessTokenProvider.GetAccessToken();
            ViewData["CategoryId"] = categoryId;

            // TODO: these coordinates should be resolved from the IP, using one of the publicly available services
            // I chose to keep them hard coded to show the value of the grouped views, for a European use-case
            ViewData["Latitude"] = 47.384860;
            ViewData["Longitude"] = 8.522303;
            return View();
        }


        // GET: /<controller>/<listingId>
        public IActionResult Listing(int eventId)
        {
            throw new NotImplementedException("Listings view is not yet implemented");
        }

        public U2EventsController(IAccessTokenProvider accessTokenProvider)
        {
            this.accessTokenProvider = accessTokenProvider;
        }
    }
}
