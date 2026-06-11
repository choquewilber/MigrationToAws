using Cignium.Hosting;
using Microsoft.Extensions.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

var ApplicationActivated = false;
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services
    //.AddSingleton(x => new SlotActivatedStartup(x.GetServices<ISlotActivatedAction>().ToList(), false))
    .Configure<SlotActivatedStartupSettings>(builder.Configuration)
    .AddSingleton<SlotActivatedStartup>()
    .AddKeyedSingleton<ISlotActivatedAction>("SlotActivationDetection", new SlotActivatedActionWrapper(x => ApplicationActivated = true))
    .AddKeyedSingleton<ISlotActivatedAction>("SlotActivationDetection", new SlotActivatedActionWrapper(x => ApplicationActivated = true));

var app = builder.Build();

var scope = app.Services.CreateScope();
var x123 = scope.ServiceProvider.GetServices<ISlotActivatedAction>();

var a2s = scope.ServiceProvider.GetServices<IServiceProviderIsKeyedService>();


var x = scope.ServiceProvider.GetService<ISlotActivatedAction>();
var x1 = scope.ServiceProvider.GetKeyedService<ISlotActivatedAction>("SlotActivationDetection2");
var x2 = scope.ServiceProvider.GetKeyedServices<ISlotActivatedAction>("SlotActivationDetection");

var t1 = scope.ServiceProvider.GetService<SlotActivatedStartup>();


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
