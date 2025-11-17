import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import SotoS3
// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "rian",
        password: Environment.get("DATABASE_PASSWORD") ?? "",
        database: Environment.get("DATABASE_NAME") ?? "gambillforestdb",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    //AWS
   let awsClient = AWSClient(credentialProvider: .static(accessKeyId: Environment.get("AWS_ACCESS_KEY_ID") ?? "", secretAccessKey: Environment.get("AWS_SECRET_ACCESS_KEY") ?? ""))
        
    app.aws.client = awsClient
    
    let s3 = S3(client: awsClient, region: .useast2)
    app.aws.s3 = s3
    
    app.routes.defaultMaxBodySize = "100mb"
    //Migrations
    app.migrations.add(CreateAddressCode())
    app.migrations.add(CreateUserRoleEnum())
    app.migrations.add(CreateUsers())
    app.migrations.add(CreateUserToken())
    app.migrations.add(CreateRegistrationToken())
    app.migrations.add(AddAddressCodeToRegistrationToken())
    app.migrations.add(AddUserProfilePhotoObjectKey())
    app.migrations.add(AddHOAPositionFieldForUser())
    try await app.autoMigrate()
    
//    app.middleware.use(RegistrationTokenMiddleware())
//    app.middleware.use(RoleProtectedMiddleware(allowedRoles: [.admin, .developer]))
//    app.middleware.use(RoleProtectedMiddleware(allowedRoles: [.developer]))
    
    try app.register(collection: AddressCodeController())
    try app.register(collection: UserController())
    

    // register routes
    try routes(app)
}
