using System;
using System.Threading.Tasks;
using GogoKit.Models.Response;

namespace EventViewer.ViagogoAPI
{
    public interface IAccessTokenProvider
    {
        Task<String> GetAccessToken();
    }
}
