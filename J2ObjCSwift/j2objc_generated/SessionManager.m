//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: Java/src/main/java/harrycheung/map/SessionManager.java
//

#include "Gate.h"
#include "GateType.h"
#include "IOSClass.h"
#include "IOSObjectArray.h"
#include "IOSPrimitiveArray.h"
#include "J2ObjC_source.h"
#include "Lap.h"
#include "Point.h"
#include "Session.h"
#include "SessionManager.h"
#include "Track.h"
#include "java/lang/System.h"
#include "java/util/Arrays.h"
#include "java/util/List.h"

@interface HCMSessionManager () {
 @public
  jint bestIndex_;
  jdouble gap_;
  IOSDoubleArray *splitGaps_;
  jint currentSplit_;
  HCMGate *nextGate_;
  HCMPoint *lastPoint_;
  jint lapNumber_;
  jdouble splitStartTime_;
}
- (instancetype)init;
@end

J2OBJC_FIELD_SETTER(HCMSessionManager, splitGaps_, IOSDoubleArray *)
J2OBJC_FIELD_SETTER(HCMSessionManager, nextGate_, HCMGate *)
J2OBJC_FIELD_SETTER(HCMSessionManager, lastPoint_, HCMPoint *)

BOOL HCMSessionManager_initialized = NO;

@implementation HCMSessionManager

HCMSessionManager * HCMSessionManager_instance_;

+ (HCMSessionManager *)getInstance {
  return HCMSessionManager_getInstance();
}

- (instancetype)init {
  return [super init];
}

- (void)startSessionWithHCMTrack:(HCMTrack *)track {
  if (session_ == nil) {
    HCMSessionManager_set_track_(self, track);
    HCMSessionManager_setAndConsume_session_(self, [[HCMSession alloc] initWithHCMTrack:track withDouble:JavaLangSystem_currentTimeMillis() / 1000.0]);
    HCMSessionManager_setAndConsume_currentLap_(self, [[HCMLap alloc] initWithHCMSession:session_ withHCMTrack:track withDouble:session_->startTime_ withInt:0]);
    [((id<JavaUtilList>) nil_chk(session_->laps_)) addWithId:currentLap_];
    HCMSessionManager_set_nextGate_(self, ((HCMTrack *) nil_chk(track))->start_);
    HCMSessionManager_set_lastPoint_(self, nil);
    lapNumber_ = 0;
    splitStartTime_ = session_->startTime_;
    if (bestLap_ != nil) {
      bestIndex_ = 0;
    }
    HCMSessionManager_setAndConsume_splitGaps_(self, [IOSDoubleArray newArrayWithLength:[track numSplits]]);
  }
}

- (void)endSession {
  if (session_ != nil) {
    HCMSessionManager_set_session_(self, nil);
  }
}

- (void)gpsWithDouble:(jdouble)latitude
           withDouble:(jdouble)longitude
           withDouble:(jdouble)speed
           withDouble:(jdouble)bearing
           withDouble:(jdouble)horizontalAccuracy
           withDouble:(jdouble)verticalAccuracy
           withDouble:(jdouble)timestamp {
  HCMPoint *point = [[[HCMPoint alloc] initWithDouble:latitude withDouble:longitude withDouble:speed withDouble:bearing withDouble:horizontalAccuracy withDouble:verticalAccuracy withDouble:timestamp] autorelease];
  if (lastPoint_ != nil) {
    HCMPoint *cross = [((HCMGate *) nil_chk(nextGate_)) crossedWithHCMPoint:lastPoint_ withHCMPoint:point];
    if (cross != nil) {
      [((HCMLap *) nil_chk(currentLap_)) addWithHCMPoint:cross];
      *IOSDoubleArray_GetRef(nil_chk(currentLap_->splits_), currentSplit_) = cross->splitTime_;
      switch ([nextGate_->type_ ordinal]) {
        case HCMGateType_START_FINISH:
        case HCMGateType_FINISH:
        if (((HCMPoint *) nil_chk([((id<JavaUtilList>) nil_chk(currentLap_->points_)) getWithInt:0]))->generated_) {
          currentLap_->valid_ = YES;
          if (bestLap_ == nil || currentLap_->duration_ < bestLap_->duration_) {
            HCMSessionManager_set_bestLap_(self, currentLap_);
          }
        }
        case HCMGateType_START:
        lapNumber_++;
        HCMSessionManager_setAndConsume_currentLap_(self, [[HCMLap alloc] initWithHCMSession:session_ withHCMTrack:track_ withDouble:cross->timestamp_ withInt:lapNumber_]);
        HCMSessionManager_setAndConsume_lastPoint_(self, [[HCMPoint alloc] initWithDouble:[cross getLatitudeDegrees] withDouble:[cross getLongitudeDegrees] withDouble:cross->speed_ withDouble:cross->bearing_ withDouble:cross->hAccuracy_ withDouble:cross->vAccuracy_ withDouble:cross->timestamp_]);
        lastPoint_->lapDistance_ = 0;
        lastPoint_->lapTime_ = 0;
        lastPoint_->generated_ = YES;
        [currentLap_ addWithHCMPoint:lastPoint_];
        [((id<JavaUtilList>) nil_chk(((HCMSession *) nil_chk(session_))->laps_)) addWithId:currentLap_];
        gap_ = 0;
        JavaUtilArrays_fillWithDoubleArray_withDouble_(splitGaps_, 0);
        bestIndex_ = 0;
        currentSplit_ = 0;
        break;
        case HCMGateType_SPLIT:
        if (bestLap_ != nil) {
          *IOSDoubleArray_GetRef(nil_chk(splitGaps_), currentSplit_) = IOSDoubleArray_Get(currentLap_->splits_, currentSplit_) - IOSDoubleArray_Get(bestLap_->splits_, currentSplit_);
        }
        currentSplit_++;
      }
      splitStartTime_ = cross->timestamp_;
      HCMSessionManager_set_nextGate_(self, IOSObjectArray_Get(nil_chk(((HCMTrack *) nil_chk(track_))->gates_), currentSplit_));
    }
    if (bestLap_ != nil && bestIndex_ < [((id<JavaUtilList>) nil_chk(bestLap_->points_)) size]) {
      while (bestIndex_ < [bestLap_->points_ size]) {
        HCMPoint *refPoint = [bestLap_->points_ getWithInt:bestIndex_];
        if (((HCMPoint *) nil_chk(refPoint))->lapDistance_ > ((HCMLap *) nil_chk(currentLap_))->distance_) {
          HCMPoint *lastRefPoint = [bestLap_->points_ getWithInt:bestIndex_ - 1];
          jdouble distanceToLastRefPoint = currentLap_->distance_ - ((HCMPoint *) nil_chk(lastRefPoint))->lapDistance_;
          if (distanceToLastRefPoint > 0) {
            jdouble sinceLastRefPoint = distanceToLastRefPoint / point->speed_;
            gap_ = point->lapTime_ - sinceLastRefPoint - lastRefPoint->lapTime_;
            *IOSDoubleArray_GetRef(nil_chk(splitGaps_), currentSplit_) = point->splitTime_ - sinceLastRefPoint - lastRefPoint->splitTime_;
          }
          break;
        }
        bestIndex_++;
      }
    }
    point->lapDistance_ = lastPoint_->lapDistance_ + [lastPoint_ distanceToWithHCMPoint:point];
    [point setLapTimeWithDouble:((HCMLap *) nil_chk(currentLap_))->startTime_ withDouble:splitStartTime_];
  }
  [((HCMLap *) nil_chk(currentLap_)) addWithHCMPoint:point];
  HCMSessionManager_set_lastPoint_(self, point);
}

- (void)dealloc {
  RELEASE_(session_);
  RELEASE_(currentLap_);
  RELEASE_(bestLap_);
  RELEASE_(track_);
  RELEASE_(splitGaps_);
  RELEASE_(nextGate_);
  RELEASE_(lastPoint_);
  [super dealloc];
}

- (void)copyAllFieldsTo:(HCMSessionManager *)other {
  [super copyAllFieldsTo:other];
  HCMSessionManager_set_session_(other, session_);
  HCMSessionManager_set_currentLap_(other, currentLap_);
  HCMSessionManager_set_bestLap_(other, bestLap_);
  HCMSessionManager_set_track_(other, track_);
  other->bestIndex_ = bestIndex_;
  other->gap_ = gap_;
  HCMSessionManager_set_splitGaps_(other, splitGaps_);
  other->currentSplit_ = currentSplit_;
  HCMSessionManager_set_nextGate_(other, nextGate_);
  HCMSessionManager_set_lastPoint_(other, lastPoint_);
  other->lapNumber_ = lapNumber_;
  other->splitStartTime_ = splitStartTime_;
}

+ (void)initialize {
  if (self == [HCMSessionManager class]) {
    JreStrongAssignAndConsume(&HCMSessionManager_instance_, nil, [[HCMSessionManager alloc] init]);
    J2OBJC_SET_INITIALIZED(HCMSessionManager)
  }
}

+ (const J2ObjcClassInfo *)__metadata {
  static const J2ObjcMethodInfo methods[] = {
    { "getInstance", NULL, "Lharrycheung.map.SessionManager;", 0x9, NULL },
    { "init", "SessionManager", NULL, 0x2, NULL },
    { "startSessionWithHCMTrack:", "startSession", "V", 0x1, NULL },
    { "endSession", NULL, "V", 0x1, NULL },
    { "gpsWithDouble:withDouble:withDouble:withDouble:withDouble:withDouble:withDouble:", "gps", "V", 0x1, NULL },
  };
  static const J2ObjcFieldInfo fields[] = {
    { "session_", NULL, 0x4, "Lharrycheung.map.Session;", NULL,  },
    { "currentLap_", NULL, 0x4, "Lharrycheung.map.Lap;", NULL,  },
    { "bestLap_", NULL, 0x4, "Lharrycheung.map.Lap;", NULL,  },
    { "track_", NULL, 0x4, "Lharrycheung.map.Track;", NULL,  },
    { "bestIndex_", NULL, 0x2, "I", NULL,  },
    { "gap_", NULL, 0x2, "D", NULL,  },
    { "splitGaps_", NULL, 0x2, "[D", NULL,  },
    { "currentSplit_", NULL, 0x2, "I", NULL,  },
    { "nextGate_", NULL, 0x2, "Lharrycheung.map.Gate;", NULL,  },
    { "lastPoint_", NULL, 0x2, "Lharrycheung.map.Point;", NULL,  },
    { "lapNumber_", NULL, 0x2, "I", NULL,  },
    { "splitStartTime_", NULL, 0x2, "D", NULL,  },
    { "instance_", NULL, 0xc, "Lharrycheung.map.SessionManager;", &HCMSessionManager_instance_,  },
  };
  static const J2ObjcClassInfo _HCMSessionManager = { 1, "SessionManager", "harrycheung.map", NULL, 0x1, 5, methods, 13, fields, 0, NULL};
  return &_HCMSessionManager;
}

@end

HCMSessionManager *HCMSessionManager_getInstance() {
  HCMSessionManager_init();
  return HCMSessionManager_instance_;
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(HCMSessionManager)
