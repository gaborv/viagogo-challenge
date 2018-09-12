using System;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using GogoKit;
using GogoKit.Models.Response;

namespace EventViewer.ViagogoAPI
{
    public class VeryBasicAccessTokenProvider : IAccessTokenProvider
    {
        public VeryBasicAccessTokenProvider()
        {
        }

        public async Task<String> GetAccessToken()
        {
            // TODO: cache tokens in session store, and replace them only when expired
            var api = new ViagogoClient(
                            new ProductHeaderValue("EventViewer"),
                            "clientId", "clientSecret");


            return (await api.OAuth2.GetClientAccessTokenAsync(new string[] { })).AccessToken;
        }
    }
}
