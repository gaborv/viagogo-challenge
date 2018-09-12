using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using GogoKit;
using GogoKit.Models.Response;
using Microsoft.AspNetCore.Mvc;

// For more information on enabling MVC for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace EventViewer.Controllers
{
    public class U2EventsController : Controller
    {
        private readonly int categoryId = 11881;

        private async Task<OAuth2Token> GetAccessToken()
        {
            // TODO: cache tokens in session store, and replace them only when expired
            var api = new ViagogoClient(
                            new ProductHeaderValue("EventViewer"),
                            "clientID", "clientSecret");
                
            return await api.OAuth2.GetClientAccessTokenAsync(new string[]{});
        }

        // GET: /<controller>/
        public async Task<IActionResult> Index()
        {
            ViewData["AccessToken"] = (await GetAccessToken()).AccessToken;
            ViewData["CategoryId"] = categoryId;
            ViewData["Latitude"] = 47.384860;
            ViewData["Longitude"] = 8.522303;
            return View();
        }


        // GET: /<controller>/<listingId>
        public IActionResult Listing(int eventId)
        {
            return View();
        }
    }
}
