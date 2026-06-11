using System.Threading;

namespace Cignium.Hosting {
    public interface ISlotActivatedAction {
        void Execute(CancellationToken token);
    }
}