import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

const config = new pulumi.Config();
const bucketName = config.get("bucketName") ?? "spacelift-solutions-demo-pulumi";
const versioningEnabled = config.getBoolean("versioningEnabled") ?? true;

const tags = {
    Environment: "demo",
    ManagedBy: "spacelift",
    Vendor: "pulumi",
};

// aws.s3.Bucket is current on provider v7; BucketV2 is the deprecated one here.
const bucket = new aws.s3.Bucket("demo", {
    bucket: bucketName,
    tags: tags,
    // Versioned buckets are non-empty, so destroy needs this.
    forceDestroy: true,
});

// Versioning and encryption are companion resources: Bucket's inline
// equivalents are deprecated in favour of these.
const versioning = new aws.s3.BucketVersioning("demo", {
    bucket: bucket.id,
    versioningConfiguration: {
        status: versioningEnabled ? "Enabled" : "Suspended",
    },
});

const encryption = new aws.s3.BucketServerSideEncryptionConfiguration("demo", {
    bucket: bucket.id,
    rules: [{
        applyServerSideEncryptionByDefault: {
            sseAlgorithm: "AES256",
        },
        bucketKeyEnabled: true,
    }],
});

const publicAccessBlock = new aws.s3.BucketPublicAccessBlock("demo", {
    bucket: bucket.id,
    blockPublicAcls: true,
    blockPublicPolicy: true,
    ignorePublicAcls: true,
    restrictPublicBuckets: true,
});

export const bucketId = bucket.id;
export const bucketArn = bucket.arn;
export const bucketDomainName = bucket.bucketDomainName;
export const bucketRegion = bucket.region;
export const versioningStatus = versioning.versioningConfiguration.status;
export const encryptionId = encryption.id;
export const publicAccessBlockId = publicAccessBlock.id;
